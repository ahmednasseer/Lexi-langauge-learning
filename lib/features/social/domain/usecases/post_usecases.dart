import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<List<Post>> call({int limit = 20}) async {
    return repository.getPosts(limit: limit);
  }
}

class GetUserPostsUseCase {
  final PostRepository repository;

  GetUserPostsUseCase(this.repository);

  Future<List<Post>> call(String userId) async {
    return repository.getUserPosts(userId);
  }
}

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> call({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
  }) async {
    return repository.createPost(
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
    );
  }
}

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> call(String postId) async {
    return repository.deletePost(postId);
  }
}

class SearchPostsUseCase {
  final PostRepository repository;

  SearchPostsUseCase(this.repository);

  Future<List<Post>> call(String query) async {
    return repository.searchPosts(query);
  }
}
