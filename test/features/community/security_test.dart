import 'package:flutter_test/flutter_test.dart';
import 'package:lexi/features/community/models/message.dart';
import 'package:lexi/features/community/security_service.dart';
import 'package:lexi/features/community/community_controller.dart';

void main() {
  group('Security Service Tests', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    test('should block a user', () {
      final result = securityService.blockUser('user_a', 'user_b');
      expect(result, true);
      expect(securityService.isBlocked('user_a', 'user_b'), true);
      expect(securityService.isBlocked('user_b', 'user_a'), true);
    });

    test('should unblock a user', () {
      securityService.blockUser('user_a', 'user_b');
      final result = securityService.unblockUser('user_a', 'user_b');
      expect(result, true);
      expect(securityService.isBlocked('user_a', 'user_b'), false);
    });

    test('should not allow duplicate blocking', () {
      securityService.blockUser('user_a', 'user_b');
      final result = securityService.blockUser('user_a', 'user_b');
      expect(result, false);
    });

    test('should prevent message request to blocked user', () {
      securityService.blockUser('user_a', 'user_b');
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      final canSend = securityService.canSendRequest('user_a', 'user_b', receiverProfile, false);
      expect(canSend, false);
    });

    test('should respect privacy setting: disabled', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.disabled,
      );
      expect(receiverProfile.canMessage, false);
      expect(receiverProfile.canSendRequest, false);
    });

    test('should respect privacy setting: friendsOnly', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.friendsOnly,
        isFriend: false,
      );
      expect(receiverProfile.canMessage, false);
      expect(receiverProfile.canSendRequest, true);
    });

    test('should respect privacy setting: everyone', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      expect(receiverProfile.canMessage, true);
    });

    test('should respect privacy setting: groupMembersOnly with common groups', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.groupMembersOnly,
        commonGroupIds: ['group1'],
      );
      expect(receiverProfile.canMessage, true);
    });

    test('should respect privacy setting: groupMembersOnly without common groups', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.groupMembersOnly,
        commonGroupIds: [],
      );
      expect(receiverProfile.canMessage, false);
    });

    test('should enforce daily message limit for free users', () {
      for (int i = 0; i < 10; i++) {
        securityService.recordMessageSent('user_a');
      }
      expect(securityService.getRemainingDailyMessages('user_a', false), 0);
    });

    test('should enforce daily message limit for premium users', () {
      for (int i = 0; i < 50; i++) {
        securityService.recordMessageSent('user_a');
      }
      expect(securityService.getRemainingDailyMessages('user_a', true), 0);
    });

    test('should report a user', () {
      final report = securityService.reportUser(
        reporterId: 'user_a',
        reportedUserId: 'user_b',
        reason: ReportReason.spam,
        description: 'Sending too many messages',
      );
      expect(report.id.isNotEmpty, true);
      expect(report.reason, ReportReason.spam);
      expect(securityService.hasUserReported('user_a', 'user_b'), true);
    });

    test('should not allow duplicate reports', () {
      securityService.reportUser(
        reporterId: 'user_a',
        reportedUserId: 'user_b',
        reason: ReportReason.spam,
      );
      expect(securityService.hasUserReported('user_a', 'user_b'), true);
    });
  });

  group('Community Controller Security Tests', () {
    late CommunityController controller;

    setUp(() {
      controller = CommunityController();
      controller.setCurrentUser('user_a');
    });

    test('should not allow messaging blocked user', () {
      controller.blockUser('user_b');
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      final result = controller.sendMessageRequest('user_b', receiverProfile);
      expect(result, 'blocked');
    });

    test('should remove conversation when blocking user', () {
      controller.blockUser('user_b');
      expect(controller.conversations.any((c) => c.otherUserId == 'user_b'), false);
    });

    test('should report a user successfully', () {
      final report = controller.reportUser(
        reportedUserId: 'user_b',
        reason: ReportReason.harassment,
        description: 'Inappropriate messages',
      );
      expect(report, isNotNull);
      expect(report!.reason, ReportReason.harassment);
    });

    test('should not allow duplicate reports', () {
      controller.reportUser(
        reportedUserId: 'user_b',
        reason: ReportReason.spam,
      );
      final secondReport = controller.reportUser(
        reportedUserId: 'user_b',
        reason: ReportReason.spam,
      );
      expect(secondReport, isNull);
    });

    test('should return blocked users list', () {
      controller.blockUser('user_b');
      controller.blockUser('user_c');
      final blockedUsers = controller.getBlockedUsers();
      expect(blockedUsers.length, 2);
    });

    test('should check if user is blocked', () {
      controller.blockUser('user_b');
      expect(controller.isUserBlocked('user_b'), true);
      expect(controller.isUserBlocked('user_c'), false);
    });
  });

  group('Message Request Flow Tests', () {
    late CommunityController controller;

    setUp(() {
      controller = CommunityController();
      controller.setCurrentUser('user_a');
    });

    test('should send message request when allowed', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      final result = controller.sendMessageRequest('user_b', receiverProfile);
      expect(result, null);
      expect(controller.messageRequests.length, greaterThan(0));
    });

    test('should accept message request', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      controller.sendMessageRequest('user_b', receiverProfile);
      final requestId = controller.messageRequests.first.id;
      controller.acceptMessageRequest(requestId);
      expect(controller.conversations.length, 1);
    });

    test('should reject message request', () {
      final receiverProfile = UserProfile(
        id: 'user_b',
        name: 'User B',
        level: 'A1',
        xp: 100,
        privacySetting: PrivacySetting.everyone,
      );
      controller.sendMessageRequest('user_b', receiverProfile);
      final requestId = controller.messageRequests.first.id;
      controller.rejectMessageRequest(requestId);
      expect(controller.conversations.length, 0);
    });
  });

  group('Report Reason Tests', () {
    test('should return correct text for report reasons', () {
      expect(SecurityService.getReportReasonText(ReportReason.spam), 'Spam');
      expect(SecurityService.getReportReasonText(ReportReason.harassment), 'Harassment');
      expect(SecurityService.getReportReasonText(ReportReason.inappropriateContent), 'Inappropriate Content');
      expect(SecurityService.getReportReasonText(ReportReason.other), 'Other');
    });
  });
}
