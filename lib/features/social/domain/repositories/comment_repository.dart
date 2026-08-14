import '../entities/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> getComments(String postId);
  Future<Comment> addComment({
    required String postId,
    required String userId,
    required String username,
    String? avatar,
    required String text,
  });
  Future<void> deleteComment(String postId, String commentId);
  Future<int> getCommentsCount(String postId);
}
