import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.userId,
    super.gems,
    super.coins,
    required super.updatedAt,
  });

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      userId: wallet.userId,
      gems: wallet.gems,
      coins: wallet.coins,
      updatedAt: wallet.updatedAt,
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json, String userId) {
    return WalletModel(
      userId: userId,
      gems: json['gems'] ?? 0,
      coins: json['coins'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gems': gems,
      'coins': coins,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class TransactionModel extends WalletTransaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    super.currency,
    required super.description,
    required super.createdAt,
    super.metadata,
  });

  factory TransactionModel.fromEntity(WalletTransaction transaction) {
    return TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      type: transaction.type,
      amount: transaction.amount,
      currency: transaction.currency,
      description: transaction.description,
      createdAt: transaction.createdAt,
      metadata: transaction.metadata,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      userId: json['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.earned,
      ),
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'gems',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}
