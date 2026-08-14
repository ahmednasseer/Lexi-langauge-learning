import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;
  final fb.FirebaseAuth _firebaseAuth;

  PostRepositoryImpl({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance;

  CollectionReference get _postsCollection => _firestore.collection('posts');

  @override
  Future<List<Post>> getPosts({int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) return [];

      final posts = snapshot.docs
          .map(
            (doc) =>
                PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();

      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId != null) {
        final postIds = posts.map((p) => p.id).toList();
        final likedIds = await _getLikedPostIds(currentUserId, postIds);
        return posts
            .map(
              (p) => p.copyWith(isLikedByCurrentUser: likedIds.contains(p.id)),
            )
            .toList();
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Post>> getUserPosts(String userId) async {
    try {
      final snapshot = await _postsCollection
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Post?> getPost(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;
      return PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Post> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
  }) async {
    try {
      final docRef = _postsCollection.doc();
      final post = Post(
        id: docRef.id,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        createdAt: DateTime.now(),
      );

      final model = PostModel.fromEntity(post);
      await docRef.set(model.toJson());
      return post;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<List<Post>> searchPosts(String query) async {
    try {
      final snapshot = await _postsCollection
          .where('content', isGreaterThanOrEqualTo: query)
          .where('content', isLessThan: '${query}z')
          .limit(20)
          .get();

      return snapshot.docs
          .map(
            (doc) =>
                PostModel.fromJson(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> _getLikedPostIds(
    String userId,
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) return [];
    try {
      final likedIds = <String>[];
      for (final postId in postIds) {
        final doc = await _postsCollection
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();
        if (doc.exists) likedIds.add(postId);
      }
      return likedIds;
    } catch (e) {
      return [];
    }
  }
}
