import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import 'auth_service.dart';

enum Environment { development, staging, production }

class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isOffline;
  final int? statusCode;

  ApiResult.success(this.data, {this.statusCode}) : error = null, isOffline = false;
  ApiResult.failure(this.error, {this.statusCode, this.isOffline = false}) : data = null;

  bool get isSuccess => data != null;
  bool get isFailure => error != null;
}

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  static Environment _environment = Environment.development;
  String? _token;
  static const int _maxRetries = 1;
  static const Duration _timeout = Duration(seconds: 30);
  final ConnectivityService _connectivity = ConnectivityService();

  /// Registered by AuthService during init. Called on HTTP 401 to refresh the
  /// auth token (e.g. Firebase ID token). Should return true if a fresh token
  /// was obtained and a retry should be attempted.
  Future<bool> Function()? onUnauthorized;

  static const Map<Environment, String> _baseUrls = {
    Environment.development: 'http://10.0.2.2:3000/api/v1',
    Environment.staging: 'https://staging-api.lexi.app/api/v1',
    Environment.production: 'https://api.lexi.app/api/v1',
  };

  String get baseUrl => _baseUrls[_environment]!;
  bool get isProduction => _environment == Environment.production;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  void setEnvironment(Environment env) {
    _environment = env;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  void setToken(String token) {
    _token = token;
    _saveToken(token);
  }

  void clearToken() {
    _token = null;
    _removeToken();
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    } catch (e) {
      debugPrint('Failed to save token: $e');
    }
  }

  Future<void> _removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    } catch (e) {
      debugPrint('Failed to remove token: $e');
    }
  }

  // ==================== CORE HTTP ====================
  Future<http.Response> _makeRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final isOffline = _connectivity.isOffline;
    if (isOffline) {
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
        isOffline: true,
      );
    }

    final uri = Uri.parse(url);
    final requestHeaders = {..._headers, ...?headers};
    http.Response? response;
    Exception? lastException;

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: requestHeaders).timeout(_timeout);
            break;
          case 'POST':
            response = await http.post(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null).timeout(_timeout);
            break;
          case 'PATCH':
            response = await http.patch(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null).timeout(_timeout);
            break;
          case 'PUT':
            response = await http.put(uri, headers: requestHeaders, body: body != null ? jsonEncode(body) : null).timeout(_timeout);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: requestHeaders).timeout(_timeout);
            break;
        }
        if (response != null) break;
      } on TimeoutException catch (e) {
        lastException = e;
        if (attempt < _maxRetries) {
          debugPrint('Request timeout, retrying (${attempt + 1}/$_maxRetries)...');
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
      } on http.ClientException catch (e) {
        lastException = e;
        if (attempt < _maxRetries) {
          debugPrint('Client error, retrying (${attempt + 1}/$_maxRetries)...');
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
      }
    }

    if (response == null) {
      throw ApiException(
        message: lastException is TimeoutException
            ? 'Request timed out. Please try again.'
            : 'Network error. Please check your connection.',
        statusCode: 0,
        isOffline: lastException is TimeoutException ? false : true,
      );
    }

    return response;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }

    String message;
    switch (response.statusCode) {
      case 400:
        message = _extractMessage(response) ?? 'Invalid request. Please check your input.';
        break;
      case 401:
        message = 'Session expired. Please log in again.';
        _handleUnauthorized();
        break;
      case 403:
        message = 'You do not have permission for this action.';
        break;
      case 404:
        message = 'Resource not found.';
        break;
      case 409:
        message = _extractMessage(response) ?? 'Conflict with existing data.';
        break;
      case 422:
        message = _extractMessage(response) ?? 'Validation error. Please check your input.';
        break;
      case 429:
        message = 'Too many requests. Please slow down.';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      case 503:
        message = 'Service temporarily unavailable. Please try again later.';
        break;
      default:
        message = _extractMessage(response) ?? 'API Error ${response.statusCode}';
    }

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      data: _tryDecodeBody(response),
    );
  }

  String? _extractMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] as String? ?? body['error'] as String?;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _tryDecodeBody(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return null;
    }
  }

  void _handleUnauthorized() {
    clearToken();
  }

  /// Performs an authenticated HTTP request with a single 401-retry.
  /// On a 401 response, [onUnauthorized] is invoked once to refresh the token;
  /// if it returns true, the request is retried with the fresh token.
  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    dynamic body,
    bool retried = false,
  }) async {
    final url = '$baseUrl$path';
    final response = await _makeRequest(method, url, headers: headers, body: body);

    if (response.statusCode == 401 && !retried) {
      final refreshed = await onUnauthorized?.call() ?? false;
      if (refreshed) {
        return _request(method, path, headers: headers, body: body, retried: true);
      }
    }
    return response;
  }

  // ==================== AUTH ====================
  Future<ApiResult<Map<String, dynamic>>> register(String name, String email, String password) async {
    try {
      final response = await _request('POST', '$baseUrl/auth/register', body: {'name': name, 'email': email, 'password': password});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _request('POST', '$baseUrl/auth/login', body: {'email': email, 'password': password});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> loginAsGuest() async {
    try {
      final response = await _request('POST', '$baseUrl/auth/guest');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== USERS ====================
  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    try {
      final response = await _request('GET', '$baseUrl/users/profile');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _request('PATCH', '$baseUrl/users/profile', body: data);
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== LESSONS ====================
  Future<ApiResult<List<dynamic>>> getLanguages() async {
    try {
      final response = await _request('GET', '$baseUrl/lessons/languages');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getLessons(String language, {String? level, String? category}) async {
    try {
      var url = '$baseUrl/lessons/$language';
      final params = <String, String>{};
      if (level != null) params['level'] = level;
      if (category != null) params['category'] = category;
      if (params.isNotEmpty) url += '?${Uri(queryParameters: params).query}';

      final response = await _request('GET', url);
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getLessonDetail(String id) async {
    try {
      final response = await _request('GET', '$baseUrl/lessons/any/$id');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== PROGRESS ====================
  Future<ApiResult<Map<String, dynamic>>> completeLesson(String lessonId, double score, int timeSpent) async {
    try {
      final response = await _request('POST', '$baseUrl/progress/complete', body: {
        'lessonId': lessonId,
        'score': score,
        'timeSpent': timeSpent,
      });
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getStats() async {
    try {
      final response = await _request('GET', '$baseUrl/progress/stats');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== AI ====================
  Future<ApiResult<Map<String, dynamic>>> sendAiMessage(String message, String learningLanguage, String nativeLanguage) async {
    try {
      final response = await _request('POST', '$baseUrl/ai/chat', body: {
        'message': message,
        'learningLanguage': learningLanguage,
        'nativeLanguage': nativeLanguage,
      });
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> aiCoachChat(String message, {String? category, String? level}) async {
    try {
      final response = await _request('POST', '$baseUrl/ai-coach/chat', body: {
        'message': message,
        if (category != null) 'category': category,
        if (level != null) 'level': level,
      });
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getChatHistory() async {
    try {
      final response = await _request('GET', '$baseUrl/ai/history');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<void>> clearChatHistory() async {
    try {
      final response = await _request('POST', '$baseUrl/ai/clear-history');
      _handleResponse(response);
      return ApiResult.success(null, statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getAiUsage() async {
    try {
      final response = await _request('GET', '$baseUrl/ai/usage');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> generateLearningPlan(Map<String, dynamic> data) async {
    try {
      final response = await _request('POST', '$baseUrl/ai/learning-plan', body: data);
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== PAYMENTS ====================
  Future<ApiResult<Map<String, dynamic>>> createCheckout(String planId) async {
    try {
      final response = await _request('POST', '$baseUrl/payments/checkout', body: {'planId': planId});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== COMMUNITY ====================
  Future<ApiResult<List<dynamic>>> getCommunityFeed({int page = 1, int limit = 20}) async {
    try {
      final response = await _request('GET', '$baseUrl/community/feed?page=$page&limit=$limit');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== ACHIEVEMENTS ====================
  Future<ApiResult<List<dynamic>>> getAchievements() async {
    try {
      final response = await _request('GET', '$baseUrl/users/achievements');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== WALLET ====================
  Future<ApiResult<Map<String, dynamic>>> spendGems(int amount, String description) async {
    try {
      final response = await _request('POST', '$baseUrl/users/wallet/spend', body: {'amount': amount, 'description': description});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== WALLET LEGACY ====================
  Future<ApiResult<Map<String, dynamic>>> getWallet() async {
    try {
      final response = await _request('GET', '$baseUrl/users/wallet');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== LEADERBOARD ====================
  Future<ApiResult<List<dynamic>>> getLeaderboard({String period = 'weekly'}) async {
    try {
      final response = await _request('GET', '$baseUrl/community/leaderboard?period=$period');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== COMMUNITY GROUPS ====================
  Future<ApiResult<List<dynamic>>> getCommunityGroups() async {
    try {
      final response = await _request('GET', '$baseUrl/community/groups');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> joinCommunityGroup(String groupId) async {
    try {
      final response = await _request('POST', '$baseUrl/community/groups/$groupId/join');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> leaveCommunityGroup(String groupId) async {
    try {
      final response = await _request('POST', '$baseUrl/community/groups/$groupId/leave');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== COMMUNITY POSTS ====================
  Future<ApiResult<List<dynamic>>> getPosts({int page = 1, int limit = 20, String? groupId, String? type}) async {
    try {
      final params = <String, String>{'page': '$page', 'limit': '$limit'};
      if (groupId != null) params['groupId'] = groupId;
      if (type != null) params['type'] = type;
      final url = '$baseUrl/community/posts?${Uri(queryParameters: params).query}';
      final response = await _request('GET', url);
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> createPost(String content, String type, {String? groupId}) async {
    try {
      final body = {'content': content, 'type': type};
      if (groupId != null) body['groupId'] = groupId;
      final response = await _request('POST', '$baseUrl/community/posts', body: body);
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> likePost(String postId) async {
    try {
      final response = await _request('POST', '$baseUrl/community/posts/$postId/like');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> unlikePost(String postId) async {
    try {
      final response = await _request('DELETE', '$baseUrl/community/posts/$postId/like');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== COMMUNITY COMMENTS ====================
  Future<ApiResult<List<dynamic>>> getComments(String postId) async {
    try {
      final response = await _request('GET', '$baseUrl/community/posts/$postId/comments');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> addComment(String postId, String text) async {
    try {
      final response = await _request('POST', '$baseUrl/community/posts/$postId/comments', body: {'text': text});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== CHALLENGES ====================
  Future<ApiResult<List<dynamic>>> getChallenges() async {
    try {
      final response = await _request('GET', '$baseUrl/community/challenges');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> joinChallenge(String challengeId) async {
    try {
      final response = await _request('POST', '$baseUrl/community/challenges/$challengeId/join');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== MESSAGES ====================
  Future<ApiResult<List<dynamic>>> getConversations() async {
    try {
      final response = await _request('GET', '$baseUrl/community/messages');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await _request('GET', '$baseUrl/community/messages/$conversationId');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> sendMessage(String receiverId, String content) async {
    try {
      final response = await _request('POST', '$baseUrl/community/messages', body: {'receiverId': receiverId, 'content': content});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> sendMessageRequest(String receiverId) async {
    try {
      final response = await _request('POST', '$baseUrl/community/messages/request', body: {'receiverId': receiverId});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== NOTIFICATIONS ====================
  Future<ApiResult<List<dynamic>>> getNotifications({int page = 1}) async {
    try {
      final response = await _request('GET', '$baseUrl/notifications?page=$page');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> markNotificationRead(String id) async {
    try {
      final response = await _request('POST', '$baseUrl/notifications/$id/read');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== STORE ====================
  Future<ApiResult<List<dynamic>>> getStoreItems({String? category}) async {
    try {
      final params = <String, String>{};
      if (category != null) params['category'] = category;
      final query = params.isNotEmpty ? '?${Uri(queryParameters: params).query}' : '';
      final response = await _request('GET', '$baseUrl/store/items$query');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getInventory() async {
    try {
      final response = await _request('GET', '$baseUrl/store/inventory');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> purchaseItem(String itemId) async {
    try {
      final response = await _request('POST', '$baseUrl/store/purchase', body: {'itemId': itemId});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> equipItem(String itemId) async {
    try {
      final response = await _request('POST', '$baseUrl/store/equip', body: {'itemId': itemId});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== SEARCH ====================
  Future<ApiResult<List<dynamic>>> search(String query, {String? type}) async {
    try {
      final params = <String, String>{'q': query};
      if (type != null) params['type'] = type;
      final response = await _request('GET', '$baseUrl/search?${Uri(queryParameters: params).query}');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== FRIENDS ====================
  Future<ApiResult<List<dynamic>>> getFriends() async {
    try {
      final response = await _request('GET', '$baseUrl/friends');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getFriendRequests() async {
    try {
      final response = await _request('GET', '$baseUrl/friends/requests');
      final data = _handleResponse(response);
      return ApiResult.success(data['data'] ?? [], statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> respondFriendRequest(String requestId, bool accept) async {
    try {
      final response = await _request('POST', '$baseUrl/friends/requests/$requestId', body: {'accept': accept});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== GROWTH ====================
  Future<ApiResult<Map<String, dynamic>>> getGrowthStats() async {
    try {
      final response = await _request('GET', '$baseUrl/users/growth');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== GOETHE ====================
  Future<ApiResult<List<dynamic>>> getGoetheLevels() async {
    try {
      final response = await _request('GET', '$baseUrl/goethe/levels');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getGoetheExams(String level) async {
    try {
      final response = await _request('GET', '$baseUrl/goethe/$level/exams');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> analyzeGoetheWriting(String text) async {
    try {
      final response = await _request('POST', '$baseUrl/goethe/writing/analyze', body: {'text': text});
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== SPEAKING ====================
  Future<ApiResult<List<dynamic>>> getSpeakingExercises(String level) async {
    try {
      final response = await _request('GET', '$baseUrl/speaking/exercises/$level');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getListeningQuestions(String level) async {
    try {
      final response = await _request('GET', '$baseUrl/speaking/listening/$level');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== CERTIFICATES ====================
  Future<ApiResult<List<dynamic>>> getCertificates() async {
    try {
      final response = await _request('GET', '$baseUrl/certificates');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> generateCertificate(String level) async {
    try {
      final response = await _request('POST', '$baseUrl/certificates/generate/$level');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== AI LEARNING ====================
  Future<ApiResult<Map<String, dynamic>>> getAiLearningProfile() async {
    try {
      final response = await _request('GET', '$baseUrl/ai-learning/profile');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getAiLearningRecommendations() async {
    try {
      final response = await _request('GET', '$baseUrl/ai-learning/recommendations');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<Map<String, dynamic>>> getAiLearningStudyPlan() async {
    try {
      final response = await _request('GET', '$baseUrl/ai-learning/study-plan');
      return ApiResult.success(_handleResponse(response), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== LIVE LEARNING ====================
  Future<ApiResult<List<dynamic>>> getLiveRooms() async {
    try {
      final response = await _request('GET', '$baseUrl/live/rooms');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getLivePartners() async {
    try {
      final response = await _request('GET', '$baseUrl/live/partners');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  Future<ApiResult<List<dynamic>>> getLiveEvents() async {
    try {
      final response = await _request('GET', '$baseUrl/live/events');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }

  // ==================== ADVANCED SPEAKING ====================
  Future<ApiResult<List<dynamic>>> getSpeakingChallenges() async {
    try {
      final userId = AuthService.instance.currentUser?.id ?? '';
      final response = await _request('GET', '$baseUrl/speaking/challenges/$userId');
      final data = _handleResponse(response);
      return ApiResult.success(data is List ? data : (data['data'] ?? []), statusCode: response.statusCode);
    } on ApiException catch (e) {
      return ApiResult.failure(e.message, statusCode: e.statusCode, isOffline: e.isOffline);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final bool isOffline;
  final Map<String, dynamic>? data;

  ApiException({
    required this.message,
    required this.statusCode,
    this.isOffline = false,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
