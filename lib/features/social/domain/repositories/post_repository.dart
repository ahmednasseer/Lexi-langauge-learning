import '../entities/post.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({int limit = 20});
  Future<List<Post>> getUserPosts(String userId);
  Future<Post?> getPost(String postId);
  Future<Post> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
  });
  Future<void> deletePost(String postId);
  Future<List<Post>> searchPosts(String query);
}
