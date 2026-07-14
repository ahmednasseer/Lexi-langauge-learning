import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  static const String baseUrl = 'https://api.lexi.com/api/v1';
  String? _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // ==================== AUTH ====================
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> loginAsGuest() async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/guest'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // ==================== USERS ====================
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/users/profile'), headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/profile'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ==================== LESSONS ====================
  Future<List<dynamic>> getLanguages() async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/languages'), headers: _headers);
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  Future<List<dynamic>> getLessons(String language, {String? level, String? category}) async {
    var url = '$baseUrl/lessons/$language';
    final params = <String, String>{};
    if (level != null) params['level'] = level;
    if (category != null) params['category'] = category;
    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }
    final response = await http.get(Uri.parse(url), headers: _headers);
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getLessonDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/any/$id'), headers: _headers);
    return _handleResponse(response);
  }

  // ==================== PROGRESS ====================
  Future<Map<String, dynamic>> completeLesson(String lessonId, double score, int timeSpent) async {
    final response = await http.post(
      Uri.parse('$baseUrl/progress/complete'),
      headers: _headers,
      body: jsonEncode({'lessonId': lessonId, 'score': score, 'timeSpent': timeSpent}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/progress/stats'), headers: _headers);
    return _handleResponse(response);
  }

  // ==================== AI ====================
  Future<Map<String, dynamic>> sendAiMessage(String message, String learningLanguage, String nativeLanguage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/chat'),
      headers: _headers,
      body: jsonEncode({'message': message, 'learningLanguage': learningLanguage, 'nativeLanguage': nativeLanguage}),
    );
    return _handleResponse(response);
  }

  Future<List<dynamic>> getChatHistory() async {
    final response = await http.get(Uri.parse('$baseUrl/ai/history'), headers: _headers);
    final data = _handleResponse(response);
    return data['data'] ?? [];
  }

  Future<void> clearChatHistory() async {
    await http.post(Uri.parse('$baseUrl/ai/clear-history'), headers: _headers);
  }

  Future<Map<String, dynamic>> getAiUsage() async {
    final response = await http.get(Uri.parse('$baseUrl/ai/usage'), headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> generateLearningPlan(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/learning-plan'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  // ==================== PAYMENTS ====================
  Future<Map<String, dynamic>> createCheckout(String planId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/checkout'),
      headers: _headers,
      body: jsonEncode({'planId': planId}),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'API Error ${response.statusCode}');
    }
  }
}
