import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../../domain/usecases/friend_usecases.dart';

// States
abstract class FriendState extends Equatable {
  const FriendState();

  @override
  List<Object?> get props => [];
}

class FriendInitial extends FriendState {}

class FriendLoading extends FriendState {}

class FriendLoaded extends FriendState {
  final List<Friend> friends;

  const FriendLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

class FriendRequestLoaded extends FriendState {
  final List<FriendRequest> requests;

  const FriendRequestLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class FriendRequestSent extends FriendState {
  final FriendRequest request;

  const FriendRequestSent(this.request);

  @override
  List<Object?> get props => [request];
}

class FriendError extends FriendState {
  final String message;

  const FriendError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FriendCubit extends Cubit<FriendState> {
  final FriendRepository repository;
  late final GetFriendsUseCase getFriendsUseCase;
  late final GetFriendRequestsUseCase getFriendRequestsUseCase;
  late final SendFriendRequestUseCase sendFriendRequestUseCase;
  late final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  late final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  late final RemoveFriendUseCase removeFriendUseCase;
  late final SearchUsersUseCase searchUsersUseCase;

  FriendCubit(this.repository) : super(FriendInitial()) {
    getFriendsUseCase = GetFriendsUseCase(repository);
    getFriendRequestsUseCase = GetFriendRequestsUseCase(repository);
    sendFriendRequestUseCase = SendFriendRequestUseCase(repository);
    acceptFriendRequestUseCase = AcceptFriendRequestUseCase(repository);
    rejectFriendRequestUseCase = RejectFriendRequestUseCase(repository);
    removeFriendUseCase = RemoveFriendUseCase(repository);
    searchUsersUseCase = SearchUsersUseCase(repository);
  }

  Future<void> loadFriends(String userId) async {
    emit(FriendLoading());
    try {
      final friends = await getFriendsUseCase(userId);
      emit(FriendLoaded(friends));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> loadFriendRequests(String userId) async {
    emit(FriendLoading());
    try {
      final requests = await getFriendRequestsUseCase(userId);
      emit(FriendRequestLoaded(requests));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> sendFriendRequest({
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    try {
      final request = await sendFriendRequestUseCase(
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverAvatar: receiverAvatar,
      );
      emit(FriendRequestSent(request));
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await acceptFriendRequestUseCase(requestId);
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await rejectFriendRequestUseCase(requestId);
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await removeFriendUseCase(userId, friendId);
      await loadFriends(userId);
    } catch (e) {
      emit(FriendError(e.toString()));
    }
  }

  Future<List<String>> searchUsers(String query) async {
    return searchUsersUseCase(query);
  }
}
