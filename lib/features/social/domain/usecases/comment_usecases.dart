import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<Comment>> call(String postId) async {
    return repository.getComments(postId);
  }
}

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<Comment> call({
    required String postId,
    required String userId,
    required String username,
    String? avatar,
    required String text,
  }) async {
    return repository.addComment(
      postId: postId,
      userId: userId,
      username: username,
      avatar: avatar,
      text: text,
    );
  }
}

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call(String postId, String commentId) async {
    return repository.deleteComment(postId, commentId);
  }
}

class GetCommentsCountUseCase {
  final CommentRepository repository;

  GetCommentsCountUseCase(this.repository);

  Future<int> call(String postId) async {
    return repository.getCommentsCount(postId);
  }
}
