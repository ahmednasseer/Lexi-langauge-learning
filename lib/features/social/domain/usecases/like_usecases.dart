import '../repositories/like_repository.dart';

class ToggleLikeUseCase {
  final LikeRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<bool> call(String postId, String userId) async {
    final isLiked = await repository.isLiked(postId, userId);
    if (isLiked) {
      await repository.unlikePost(postId, userId);
      return false;
    } else {
      await repository.likePost(postId, userId);
      return true;
    }
  }
}

class IsLikedUseCase {
  final LikeRepository repository;

  IsLikedUseCase(this.repository);

  Future<bool> call(String postId, String userId) async {
    return repository.isLiked(postId, userId);
  }
}

class GetLikesCountUseCase {
  final LikeRepository repository;

  GetLikesCountUseCase(this.repository);

  Future<int> call(String postId) async {
    return repository.getLikesCount(postId);
  }
}

class GetLikedPostIdsUseCase {
  final LikeRepository repository;

  GetLikedPostIdsUseCase(this.repository);

  Future<List<String>> call(String userId, List<String> postIds) async {
    return repository.getLikedPostIds(userId, postIds);
  }
}
