import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String userId;
  final int gems;
  final int coins;
  final DateTime updatedAt;

  const Wallet({
    required this.userId,
    this.gems = 0,
    this.coins = 0,
    required this.updatedAt,
  });

  bool canAfford({int gems = 0, int coins = 0}) {
    return this.gems >= gems && this.coins >= coins;
  }

  Wallet copyWith({
    String? userId,
    int? gems,
    int? coins,
    DateTime? updatedAt,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      gems: gems ?? this.gems,
      coins: coins ?? this.coins,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [userId, gems, coins, updatedAt];
}

enum TransactionType { earned, spent, purchase, reward, refund }

class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String currency;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'gems',
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  WalletTransaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    String? currency,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    currency,
    description,
    createdAt,
    metadata,
  ];
}
