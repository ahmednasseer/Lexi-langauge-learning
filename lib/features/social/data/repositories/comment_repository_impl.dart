import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirebaseFirestore _firestore;

  CommentRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _commentsCollection(String postId) =>
      _firestore.collection('posts').doc(postId).collection('comments');

  @override
  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _commentsCollection(
        postId,
      ).orderBy('createdAt', descending: false).get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map(
            (doc) => CommentModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String username,
    String? avatar,
    required String text,
  }) async {
    try {
      final docRef = _commentsCollection(postId).doc();
      final comment = Comment(
        id: docRef.id,
        postId: postId,
        userId: userId,
        username: username,
        avatar: avatar,
        text: text,
        createdAt: DateTime.now(),
      );

      final model = CommentModel.fromEntity(comment);
      await docRef.set(model.toJson());

      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      return comment;
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _commentsCollection(postId).doc(commentId).delete();

      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }

  @override
  Future<int> getCommentsCount(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (!doc.exists) return 0;
      final data = doc.data();
      return data?['commentsCount'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
