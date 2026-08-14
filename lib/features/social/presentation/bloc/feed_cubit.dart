import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/post_usecases.dart';

// States
abstract class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Post> posts;

  const FeedLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}

class FeedError extends FeedState {
  final String message;

  const FeedError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FeedCubit extends Cubit<FeedState> {
  final PostRepository repository;
  late final GetPostsUseCase getPostsUseCase;
  late final GetUserPostsUseCase getUserPostsUseCase;
  late final CreatePostUseCase createPostUseCase;
  late final DeletePostUseCase deletePostUseCase;
  late final SearchPostsUseCase searchPostsUseCase;

  FeedCubit(this.repository) : super(FeedInitial()) {
    getPostsUseCase = GetPostsUseCase(repository);
    getUserPostsUseCase = GetUserPostsUseCase(repository);
    createPostUseCase = CreatePostUseCase(repository);
    deletePostUseCase = DeletePostUseCase(repository);
    searchPostsUseCase = SearchPostsUseCase(repository);
  }

  Future<void> loadPosts({int limit = 20}) async {
    emit(FeedLoading());
    try {
      final posts = await getPostsUseCase(limit: limit);
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> loadUserPosts(String userId) async {
    emit(FeedLoading());
    try {
      final posts = await getUserPostsUseCase(userId);
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
  }) async {
    try {
      await createPostUseCase(
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
      );
      await loadPosts();
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await deletePostUseCase(postId);
      await loadPosts();
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<List<Post>> searchPosts(String query) async {
    return searchPostsUseCase(query);
  }

  void updatePostInList(Post updatedPost) {
    final currentState = state;
    if (currentState is FeedLoaded) {
      final updatedPosts = currentState.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList();
      emit(FeedLoaded(updatedPosts));
    }
  }
}
