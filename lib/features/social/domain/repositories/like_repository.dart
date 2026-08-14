abstract class LikeRepository {
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  Future<bool> isLiked(String postId, String userId);
  Future<int> getLikesCount(String postId);
  Future<List<String>> getLikedPostIds(String userId, List<String> postIds);
}
