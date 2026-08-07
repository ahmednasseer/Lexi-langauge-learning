import 'package:flutter/material.dart';
import 'models/community_group.dart';
import 'models/community_post.dart';
import 'models/community_comment.dart';
import 'models/challenge.dart';
import 'models/community_user.dart';
import 'models/message.dart';
import 'community_repository.dart';
import 'leaderboard_repository.dart';
import 'security_service.dart';

enum CommunityTab { feed, groups, challenges, messages }

class CommunityController extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  CommunityTab _selectedTab = CommunityTab.feed;
  List<CommunityGroup> _groups = [];
  List<CommunityPost> _posts = [];
  List<Challenge> _challenges = [];
  List<CommunityUser> _leaderboard = [];
  final List<Conversation> _conversations = [];
  final List<MessageRequest> _messageRequests = [];
  bool _isLoading = false;
  String _currentUserId = 'current_user';
  bool _isPremium = false;

  CommunityTab get selectedTab => _selectedTab;
  List<CommunityGroup> get groups => _groups;
  List<CommunityPost> get posts => _posts;
  List<Challenge> get challenges => _challenges;
  List<CommunityUser> get leaderboard => _leaderboard;
  List<Conversation> get conversations => _conversations;
  List<MessageRequest> get messageRequests => _messageRequests;
  bool get isLoading => _isLoading;
  SecurityService get securityService => _securityService;

  int get unreadMessages => _conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
  int get pendingRequests => _messageRequests.where((r) => r.status == MessageRequestStatus.pending).length;
  int get remainingMessages => _securityService.getRemainingDailyMessages(_currentUserId, _isPremium);

  CommunityController() {
    _loadData();
  }

  void setCurrentUser(String userId, {bool isPremium = false}) {
    _currentUserId = userId;
    _isPremium = isPremium;
    notifyListeners();
  }

  void setTab(CommunityTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  List<CommunityTab> get tabs => [
    CommunityTab.feed,
    CommunityTab.groups,
    CommunityTab.challenges,
    CommunityTab.messages,
  ];

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final repo = CommunityRepository();
      final results = await Future.wait([
        repo.getGroups(),
        repo.getFeed(),
        repo.getChallenges(),
        LeaderboardRepository().getLeaderboard(),
      ]);

      _groups = results[0] as List<CommunityGroup>;
      _posts = results[1] as List<CommunityPost>;
      _challenges = results[2] as List<Challenge>;
      _leaderboard = results[3] as List<CommunityUser>;
    } catch (e) {
      debugPrint('Error loading community data: $e');
      _leaderboard = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  void toggleGroupJoin(String groupId) {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      final group = _groups[index];
      _groups[index] = group.copyWith(
        isJoined: !group.isJoined,
        memberCount: group.isJoined ? group.memberCount - 1 : group.memberCount + 1,
      );
      notifyListeners();
      CommunityRepository().joinGroup(groupId);
    }
  }

  void togglePostLike(String postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final nowLiked = !post.isLiked;
      _posts[index] = post.copyWith(
        isLiked: nowLiked,
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
      );
      notifyListeners();
      CommunityRepository().toggleLike(postId, post.isLiked);
    }
  }

  void addPost(String content, PostType type) {
    final newPost = CommunityPost(
      id: 'p${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId,
      userName: 'You',
      userLevel: 'A2',
      userXp: 1500,
      content: content,
      type: type,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    notifyListeners();
    CommunityRepository().createPost(content, type.name);
  }

  void addComment(String postId, String text) {
    CommunityComment(
      id: 'c${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: _currentUserId,
      userName: 'You',
      userLevel: 'A2',
      text: text,
      createdAt: DateTime.now(),
    );
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      _posts[postIndex] = _posts[postIndex].copyWith(
        commentsCount: _posts[postIndex].commentsCount + 1,
      );
    }
    notifyListeners();
    CommunityRepository().addComment(postId, text);
  }

  void joinChallenge(String challengeId) {
    notifyListeners();
    CommunityRepository().joinChallenge(challengeId);
  }

  String? sendMessageRequest(String receiverId, UserProfile receiverProfile) {
    if (!_securityService.canSendRequest(_currentUserId, receiverId, receiverProfile, _isPremium)) {
      if (_securityService.isBlocked(_currentUserId, receiverId)) {
        return 'blocked';
      }
      if (!_securityService.canSendMessage(_currentUserId, receiverId, _isPremium)) {
        return 'rate_limit';
      }
      return 'permission_denied';
    }

    final existing = _messageRequests.firstWhere(
      (r) => r.senderId == _currentUserId && r.receiverId == receiverId && r.status == MessageRequestStatus.pending,
      orElse: () => MessageRequest(id: '', senderId: '', senderName: '', receiverId: '', createdAt: DateTime.now()),
    );
    if (existing.id.isNotEmpty) return 'already_sent';

    final newRequest = MessageRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId,
      senderName: 'You',
      receiverId: receiverId,
      status: MessageRequestStatus.pending,
      createdAt: DateTime.now(),
    );
    _messageRequests.add(newRequest);
    _securityService.recordMessageSent(_currentUserId);
    notifyListeners();
    return null;
  }

  void acceptMessageRequest(String requestId) {
    final index = _messageRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _messageRequests[index] = MessageRequest(
        id: _messageRequests[index].id,
        senderId: _messageRequests[index].senderId,
        senderName: _messageRequests[index].senderName,
        receiverId: _messageRequests[index].receiverId,
        status: MessageRequestStatus.accepted,
        createdAt: _messageRequests[index].createdAt,
      );
      _conversations.add(Conversation(
        id: 'conv_${_messageRequests[index].senderId}',
        otherUserId: _messageRequests[index].senderId,
        otherUserName: _messageRequests[index].senderName,
        lastMessage: null,
        unreadCount: 0,
      ));
      notifyListeners();
    }
  }

  void rejectMessageRequest(String requestId) {
    final index = _messageRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _messageRequests[index] = MessageRequest(
        id: _messageRequests[index].id,
        senderId: _messageRequests[index].senderId,
        senderName: _messageRequests[index].senderName,
        receiverId: _messageRequests[index].receiverId,
        status: MessageRequestStatus.rejected,
        createdAt: _messageRequests[index].createdAt,
      );
      notifyListeners();
    }
  }

  bool blockUser(String targetUserId) {
    final success = _securityService.blockUser(_currentUserId, targetUserId);
    if (success) {
      _messageRequests.removeWhere((r) =>
        (r.senderId == _currentUserId && r.receiverId == targetUserId) ||
        (r.senderId == targetUserId && r.receiverId == _currentUserId)
      );
      _conversations.removeWhere((c) => c.otherUserId == targetUserId);
      notifyListeners();
    }
    return success;
  }

  bool unblockUser(String targetUserId) {
    return _securityService.unblockUser(_currentUserId, targetUserId);
  }

  UserReport? reportUser({
    required String reportedUserId,
    String? messageId,
    required ReportReason reason,
    String? description,
  }) {
    if (_securityService.hasUserReported(_currentUserId, reportedUserId)) {
      return null;
    }
    final report = _securityService.reportUser(
      reporterId: _currentUserId,
      reportedUserId: reportedUserId,
      messageId: messageId,
      reason: reason,
      description: description,
    );
    notifyListeners();
    return report;
  }

  List<BlockedUser> getBlockedUsers() {
    return _securityService.blockedUsers.where((b) => b.blockerId == _currentUserId).toList();
  }

  bool isUserBlocked(String userId) {
    return _securityService.isBlocked(_currentUserId, userId);
  }
}
