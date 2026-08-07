import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import 'models/community_post.dart';
import 'models/community_group.dart';
import 'models/community_comment.dart';
import 'models/challenge.dart';
import 'models/message.dart';

class CommunityRepository {
  final ApiService _api = ApiService();

  Future<List<CommunityPost>> getFeed({int page = 1, int limit = 20}) async {
    try {
      final result = await _api.getCommunityFeed(page: page, limit: limit);
      if (result.isSuccess && result.data!.isNotEmpty) {
        final posts = result.data!.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>)).toList();
        await _cache('community_feed', posts.map((p) => p.toJson()).toList());
        return posts;
      }
    } catch (_) {}
    return (await _cachedPosts()) ?? [];
  }

  Future<List<CommunityGroup>> getGroups() async {
    try {
      final result = await _api.getCommunityGroups();
      if (result.isSuccess && result.data!.isNotEmpty) {
        final groups = result.data!.map((e) => CommunityGroup.fromJson(e as Map<String, dynamic>)).toList();
        await _cache('community_groups', groups.map((g) => g.toJson()).toList());
        return groups;
      }
    } catch (_) {}
    return (await _cachedGroups()) ?? [];
  }

  Future<List<Challenge>> getChallenges() async {
    try {
      final result = await _api.getChallenges();
      if (result.isSuccess && result.data!.isNotEmpty) {
        final challenges = result.data!.map((e) => Challenge.fromJson(e as Map<String, dynamic>)).toList();
        await _cache('community_challenges', challenges.map((c) => c.toJson()).toList());
        return challenges;
      }
    } catch (_) {}
    return (await _cachedChallenges()) ?? [];
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final result = await _api.getComments(postId);
      if (result.isSuccess) {
        return result.data!.map((e) => CommunityComment.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> createPost(String content, String type, {String? groupId}) async {
    try {
      await _api.createPost(content, type, groupId: groupId);
    } catch (_) {}
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    try {
      await _api.likePost(postId);
    } catch (_) {}
  }

  Future<void> addComment(String postId, String text) async {
    try {
      await _api.addComment(postId, text);
    } catch (_) {}
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await _api.joinCommunityGroup(groupId);
    } catch (_) {}
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _api.joinCommunityGroup(groupId);
    } catch (_) {}
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      await _api.joinChallenge(challengeId);
    } catch (_) {}
  }

  // ==================== MESSAGES ====================
  Future<List<Conversation>> getConversations() async {
    try {
      final result = await _api.getConversations();
      if (result.isSuccess && result.data!.isNotEmpty) {
        return result.data!.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final result = await _api.getMessages(conversationId);
      if (result.isSuccess) {
        return result.data!.map((e) => Message.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> sendMessage(String receiverId, String content) async {
    try {
      await _api.sendMessage(receiverId, content);
    } catch (_) {}
  }

  Future<void> sendMessageRequest(String receiverId) async {
    try {
      await _api.sendMessageRequest(receiverId);
    } catch (_) {}
  }

  // ==================== LOCAL CACHE ====================
  Future<void> _cache(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>?> _readCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return null;
  }

  Future<List<CommunityPost>?> _cachedPosts() async {
    final cached = await _readCache('community_feed');
    return cached?.map((e) => CommunityPost.fromJson(e)).toList();
  }

  Future<List<CommunityGroup>?> _cachedGroups() async {
    final cached = await _readCache('community_groups');
    return cached?.map((e) => CommunityGroup.fromJson(e)).toList();
  }

  Future<List<Challenge>?> _cachedChallenges() async {
    final cached = await _readCache('community_challenges');
    return cached?.map((e) => Challenge.fromJson(e)).toList();
  }
}
