class GemsWallet {
  final String userId;
  final int gems;
  final int totalPurchased;
  final int totalSpent;

  const GemsWallet({
    required this.userId,
    this.gems = 0,
    this.totalPurchased = 0,
    this.totalSpent = 0,
  });

  GemsWallet copyWith({int? gems, int? totalPurchased, int? totalSpent}) {
    return GemsWallet(
      userId: userId,
      gems: gems ?? this.gems,
      totalPurchased: totalPurchased ?? this.totalPurchased,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'gems': gems,
    'totalPurchased': totalPurchased,
    'totalSpent': totalSpent,
  };

  factory GemsWallet.fromJson(Map<String, dynamic> json) => GemsWallet(
    userId: json['userId'] ?? '',
    gems: json['gems'] ?? 0,
    totalPurchased: json['totalPurchased'] ?? 0,
    totalSpent: json['totalSpent'] ?? 0,
  );
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String description;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.purchase || type == TransactionType.reward || type == TransactionType.bundle;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'amount': amount,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] ?? '',
    userId: json['userId'] ?? '',
    type: TransactionType.values.firstWhere((e) => e.name == json['type'], orElse: () => TransactionType.purchase),
    amount: json['amount'] ?? 0,
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}

enum TransactionType { purchase, reward, spending, bundle, refund }
