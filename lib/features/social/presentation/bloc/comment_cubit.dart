import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/usecases/comment_usecases.dart';

// States
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;

  const CommentLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentAdded extends CommentState {
  final Comment comment;

  const CommentAdded(this.comment);

  @override
  List<Object?> get props => [comment];
}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class CommentCubit extends Cubit<CommentState> {
  final CommentRepository repository;
  late final GetCommentsUseCase getCommentsUseCase;
  late final AddCommentUseCase addCommentUseCase;
  late final DeleteCommentUseCase deleteCommentUseCase;
  late final GetCommentsCountUseCase getCommentsCountUseCase;

  CommentCubit(this.repository) : super(CommentInitial()) {
    getCommentsUseCase = GetCommentsUseCase(repository);
    addCommentUseCase = AddCommentUseCase(repository);
    deleteCommentUseCase = DeleteCommentUseCase(repository);
    getCommentsCountUseCase = GetCommentsCountUseCase(repository);
  }

  Future<void> loadComments(String postId) async {
    emit(CommentLoading());
    try {
      final comments = await getCommentsUseCase(postId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String username,
    String? avatar,
    required String text,
  }) async {
    try {
      final comment = await addCommentUseCase(
        postId: postId,
        userId: userId,
        username: username,
        avatar: avatar,
        text: text,
      );
      emit(CommentAdded(comment));
      await loadComments(postId);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await deleteCommentUseCase(postId, commentId);
      await loadComments(postId);
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<int> getCommentsCount(String postId) async {
    return getCommentsCountUseCase(postId);
  }
}
