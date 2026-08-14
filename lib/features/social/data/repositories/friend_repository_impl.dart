import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../models/friend_model.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FirebaseFirestore _firestore;

  FriendRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _friendRequestsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('friendRequests');

  CollectionReference _friendsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('friends');

  @override
  Future<List<Friend>> getFriends(String userId) async {
    try {
      final snapshot = await _friendsCollection(userId).get();
      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map(
            (doc) => FriendModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getFriendRequests(String userId) async {
    try {
      final snapshot = await _friendRequestsCollection(userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map(
            (doc) => FriendRequestModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<FriendRequest>> getSentRequests(String userId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('friendRequests')
          .where('senderId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((doc) => FriendRequestModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FriendRequest> sendFriendRequest({
    required String senderId,
    required String senderName,
    String? senderAvatar,
    required String receiverId,
    required String receiverName,
    String? receiverAvatar,
  }) async {
    try {
      final docRef = _friendRequestsCollection(receiverId).doc();
      final request = FriendRequest(
        id: docRef.id,
        senderId: senderId,
        senderName: senderName,
        senderAvatar: senderAvatar,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverAvatar: receiverAvatar,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      final model = FriendRequestModel.fromEntity(request);
      await docRef.set(model.toJson());
      return request;
    } catch (e) {
      throw Exception('Failed to send friend request: $e');
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'accepted',
      });
    } catch (e) {
      throw Exception('Failed to accept friend request: $e');
    }
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception('Failed to reject friend request: $e');
    }
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await _friendsCollection(userId).doc(friendId).delete();
      await _friendsCollection(friendId).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to remove friend: $e');
    }
  }

  @override
  Future<bool> isFriend(String userId, String friendId) async {
    try {
      final doc = await _friendsCollection(userId).doc(friendId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> searchUsers(String query, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}
