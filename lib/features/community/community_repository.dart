import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    final result = await _api.getCommunityFeed(page: page, limit: limit);
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load community feed');
    }
    final posts = result.data!
        .map((e) => CommunityPost.fromJson(e as Map<String, dynamic>))
        .toList();
    await _cache('community_feed', posts.map((p) => p.toJson()).toList());
    return posts;
  }

  Future<List<CommunityGroup>> getGroups() async {
    final result = await _api.getCommunityGroups();
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load community groups');
    }
    final groups = result.data!
        .map((e) => CommunityGroup.fromJson(e as Map<String, dynamic>))
        .toList();
    await _cache(
      'community_groups',
      groups.map((g) => g.toJson()).toList(),
    );
    return groups;
  }

  Future<List<Challenge>> getChallenges() async {
    final result = await _api.getChallenges();
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load challenges');
    }
    final challenges = result.data!
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList();
    await _cache(
      'community_challenges',
      challenges.map((c) => c.toJson()).toList(),
    );
    return challenges;
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    final result = await _api.getComments(postId);
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load comments');
    }
    return result.data!
        .map((e) => CommunityComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createPost(
    String content,
    String type, {
    String? groupId,
  }) async {
    final result = await _api.createPost(content, type, groupId: groupId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to create post');
    }
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    final result = await _api.likePost(postId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to toggle like');
    }
  }

  Future<void> addComment(String postId, String text) async {
    final result = await _api.addComment(postId, text);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to add comment');
    }
  }

  Future<void> joinGroup(String groupId) async {
    final result = await _api.joinCommunityGroup(groupId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to join group');
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final result = await _api.joinCommunityGroup(groupId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to leave group');
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    final result = await _api.joinChallenge(challengeId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to join challenge');
    }
  }

  // ==================== MESSAGES ====================
  Future<List<Conversation>> getConversations() async {
    final result = await _api.getConversations();
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load conversations');
    }
    return result.data!
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final result = await _api.getMessages(conversationId);
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.error ?? 'Failed to load messages');
    }
    return result.data!
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendMessage(String receiverId, String content) async {
    final result = await _api.sendMessage(receiverId, content);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to send message');
    }
  }

  Future<void> sendMessageRequest(String receiverId) async {
    final result = await _api.sendMessageRequest(receiverId);
    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Failed to send message request');
    }
  }

  // ==================== LOCAL CACHE ====================
  Future<void> _cache(String key, List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to cache $key: $e');
    }
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
    } catch (e) {
      debugPrint('Failed to read cache $key: $e');
    }
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
