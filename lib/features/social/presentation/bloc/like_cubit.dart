import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/like_repository.dart';
import '../../domain/usecases/like_usecases.dart';

// States
abstract class LikeState extends Equatable {
  const LikeState();

  @override
  List<Object?> get props => [];
}

class LikeInitial extends LikeState {}

class LikeUpdating extends LikeState {}

class LikeUpdated extends LikeState {
  final String postId;
  final bool isLiked;
  final int likesCount;

  const LikeUpdated({
    required this.postId,
    required this.isLiked,
    required this.likesCount,
  });

  @override
  List<Object?> get props => [postId, isLiked, likesCount];
}

class LikeError extends LikeState {
  final String message;

  const LikeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class LikeCubit extends Cubit<LikeState> {
  final LikeRepository repository;
  late final ToggleLikeUseCase toggleLikeUseCase;
  late final IsLikedUseCase isLikedUseCase;
  late final GetLikesCountUseCase getLikesCountUseCase;
  late final GetLikedPostIdsUseCase getLikedPostIdsUseCase;

  LikeCubit(this.repository) : super(LikeInitial()) {
    toggleLikeUseCase = ToggleLikeUseCase(repository);
    isLikedUseCase = IsLikedUseCase(repository);
    getLikesCountUseCase = GetLikesCountUseCase(repository);
    getLikedPostIdsUseCase = GetLikedPostIdsUseCase(repository);
  }

  Future<void> toggleLike(String postId, String userId) async {
    emit(LikeUpdating());
    try {
      final isLiked = await toggleLikeUseCase(postId, userId);
      final count = await getLikesCountUseCase(postId);
      emit(LikeUpdated(postId: postId, isLiked: isLiked, likesCount: count));
    } catch (e) {
      emit(LikeError(e.toString()));
    }
  }

  Future<bool> isLiked(String postId, String userId) async {
    return isLikedUseCase(postId, userId);
  }

  Future<int> getLikesCount(String postId) async {
    return getLikesCountUseCase(postId);
  }

  Future<List<String>> getLikedPostIds(
    String userId,
    List<String> postIds,
  ) async {
    return getLikedPostIdsUseCase(userId, postIds);
  }
}
