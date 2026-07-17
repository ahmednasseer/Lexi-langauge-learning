import 'package:flutter_test/flutter_test.dart';
import 'package:lexi/features/wallet/models/gems_wallet.dart';
import 'package:lexi/features/growth/models/gamification_models.dart';

void main() {
  group('Transaction model', () {
    test('serializes and deserializes correctly', () {
      final tx = Transaction(
        id: 't1',
        userId: 'u1',
        type: TransactionType.purchase,
        amount: 100,
        description: 'Starter pack',
        createdAt: DateTime(2026, 1, 1, 12, 0),
      );
      final json = tx.toJson();
      final restored = Transaction.fromJson(json);
      expect(restored.id, 't1');
      expect(restored.userId, 'u1');
      expect(restored.amount, 100);
      expect(restored.type, TransactionType.purchase);
      expect(restored.isCredit, true);
    });

    test('isCredit is true for reward/bundle/purchase', () {
      expect(Transaction(id: 'a', userId: 'u', type: TransactionType.reward, amount: 1, description: '', createdAt: DateTime.now()).isCredit, true);
      expect(Transaction(id: 'a', userId: 'u', type: TransactionType.spending, amount: 1, description: '', createdAt: DateTime.now()).isCredit, false);
    });

    test('handles unknown type gracefully', () {
      final tx = Transaction.fromJson({'type': 'weird', 'amount': 5, 'id': 'x', 'userId': 'u', 'description': 'd', 'createdAt': '2026-01-01T00:00:00.000'});
      expect(tx.type, TransactionType.purchase);
    });
  });

  group('GemsWallet model', () {
    test('copyWith preserves values', () {
      const wallet = GemsWallet(userId: 'u', gems: 50, totalPurchased: 10, totalSpent: 5);
      final updated = wallet.copyWith(gems: 60);
      expect(updated.gems, 60);
      expect(updated.totalPurchased, 10);
      expect(updated.userId, 'u');
    });

    test('fromJson tolerates missing fields', () {
      final wallet = GemsWallet.fromJson({'userId': 'u'});
      expect(wallet.gems, 0);
      expect(wallet.totalSpent, 0);
    });
  });

  group('UserProgress model', () {
    test('fromJson maps known fields', () {
      final p = UserProgress.fromJson({'totalXp': 1200, 'currentLevel': 5, 'gems': 80, 'streak': 3});
      expect(p.totalXp, 1200);
      expect(p.currentLevel, 5);
      expect(p.streak, 3);
    });

    test('copyWith merges', () {
      const p = UserProgress(totalXp: 100, currentLevel: 1, gems: 0, streak: 0);
      final updated = p.copyWith(totalXp: 200, streak: 7);
      expect(updated.totalXp, 200);
      expect(updated.streak, 7);
      expect(updated.currentLevel, 1);
    });

    test('empty() has zeroed values', () {
      final p = UserProgress.empty();
      expect(p.totalXp, 0);
      expect(p.gems, 0);
    });
  });
}
