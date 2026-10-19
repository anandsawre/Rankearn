/// Wallet Ledger Transaction Model
class WalletTransactionModel {
  final String id;
  final String userId;
  final int amount; // positive for earn, negative for spend
  final String type; // 'earn' | 'spend'
  final String category;
  final String? referenceId;
  final String title;
  final int balanceAfter;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    this.referenceId,
    required this.title,
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isEarn => type == 'earn' || amount > 0;

  factory WalletTransactionModel.fromMap(Map<String, dynamic> map) {
    return WalletTransactionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? map['userId']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      type: map['type']?.toString() ?? 'earn',
      category: map['category']?.toString() ?? 'reward',
      referenceId: map['reference_id']?.toString(),
      title: map['title']?.toString() ?? map['testTitle']?.toString() ?? 'Transaction',
      balanceAfter: (map['balance_after'] as num?)?.toInt() ?? (map['currentBalance'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : map['timestamp'] != null
              ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'reference_id': referenceId,
      'title': title,
      'balance_after': balanceAfter,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
