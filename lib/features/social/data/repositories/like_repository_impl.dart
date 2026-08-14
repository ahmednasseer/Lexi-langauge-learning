import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  final FirebaseFirestore _firestore;

  LikeRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _likesCollection(String postId) =>
      _firestore.collection('posts').doc(postId).collection('likes');

  DocumentReference _likeDoc(String postId, String userId) =>
      _likesCollection(postId).doc(userId);

  @override
  Future<void> likePost(String postId, String userId) async {
    try {
      await _likeDoc(
        postId,
        userId,
      ).set({'userId': userId, 'likedAt': DateTime.now().toIso8601String()});

      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to like post: $e');
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _likeDoc(postId, userId).delete();

      await _firestore.collection('posts').doc(postId).update({
        'likesCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unlike post: $e');
    }
  }

  @override
  Future<bool> isLiked(String postId, String userId) async {
    try {
      final doc = await _likeDoc(postId, userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getLikesCount(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return 0;
      final data = doc.data();
      return data?['likesCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<List<String>> getLikedPostIds(
    String userId,
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) return [];
    try {
      final likedIds = <String>[];
      for (final postId in postIds) {
        final doc = await _likeDoc(postId, userId).get();
        if (doc.exists) likedIds.add(postId);
      }
      return likedIds;
    } catch (e) {
      return [];
    }
  }
}
