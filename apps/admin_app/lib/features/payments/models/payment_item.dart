import 'package:flutter/material.dart';

enum PaymentPurpose {
  testSeries('Test Series', Color(0xFFF5F3FF), Color(0xFFDDD6FE), Color(0xFF6B4EFF)),
  liveQuiz('Live Quiz', Color(0xFFEFF6FF), Color(0xFFBFDBFE), Color(0xFF2587F8)),
  tournament('Tournament', Color(0xFFFFF1F2), Color(0xFFFECDD3), Color(0xFFF04483)),
  subscription('Subscription', Color(0xFFFFFBEB), Color(0xFFFDE68A), Color(0xFFFF9F0A));

  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const PaymentPurpose(this.label, this.backgroundColor, this.borderColor, this.textColor);

  static PaymentPurpose fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '')) {
      case 'testseries':
      case 'tests':
        return PaymentPurpose.testSeries;
      case 'livequiz':
      case 'quiz':
        return PaymentPurpose.liveQuiz;
      case 'tournament':
      case 'tournaments':
        return PaymentPurpose.tournament;
      case 'subscription':
      case 'plan':
        return PaymentPurpose.subscription;
      default:
        return PaymentPurpose.testSeries;
    }
  }
}

enum PaymentMethodType {
  razorpay('Razorpay', Icons.payment_rounded, Color(0xFF2587F8)),
  upi('UPI', Icons.account_balance_rounded, Color(0xFF10B981)),
  creditCard('Credit Card', Icons.credit_card_rounded, Color(0xFF6B4EFF)),
  debitCard('Debit Card', Icons.credit_card_outlined, Color(0xFF2587F8)),
  netBanking('Net Banking', Icons.account_balance_rounded, Color(0xFF0284C7)),
  wallet('Wallet', Icons.account_balance_wallet_rounded, Color(0xFFFF9F0A)),
  others('Others', Icons.devices_other_rounded, Color(0xFF64748B));

  final String label;
  final IconData icon;
  final Color brandColor;

  const PaymentMethodType(this.label, this.icon, this.brandColor);

  static PaymentMethodType fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '')) {
      case 'razorpay':
        return PaymentMethodType.razorpay;
      case 'upi':
        return PaymentMethodType.upi;
      case 'creditcard':
      case 'card':
        return PaymentMethodType.creditCard;
      case 'debitcard':
        return PaymentMethodType.debitCard;
      case 'netbanking':
      case 'bank':
        return PaymentMethodType.netBanking;
      case 'wallet':
        return PaymentMethodType.wallet;
      default:
        return PaymentMethodType.others;
    }
  }
}

enum PaymentStatus {
  success('Success', Color(0xFFDCFCE7), Color(0xFF16A34A)),
  failed('Failed', Color(0xFFFEE2E2), Color(0xFFDC2626)),
  pending('Pending', Color(0xFFFEF3C7), Color(0xFFD97706)),
  refunded('Refunded', Color(0xFFF1F5F9), Color(0xFF64748B)),
  partiallyRefunded('Partially Refunded', Color(0xFFE0E7FF), Color(0xFF4338CA));

  final String label;
  final Color backgroundColor;
  final Color color;

  const PaymentStatus(this.label, this.backgroundColor, this.color);

  static PaymentStatus fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '')) {
      case 'success':
      case 'successful':
      case 'completed':
        return PaymentStatus.success;
      case 'failed':
      case 'failure':
      case 'rejected':
        return PaymentStatus.failed;
      case 'pending':
      case 'processing':
        return PaymentStatus.pending;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'partiallyrefunded':
        return PaymentStatus.partiallyRefunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

class PaymentItem {
  final String id;
  final String userName;
  final String userEmail;
  final Color userAvatarBg;
  final PaymentPurpose purpose;
  final double amount;
  final PaymentMethodType paymentMethod;
  final String transactionId;
  final String orderId;
  final PaymentStatus status;
  final DateTime dateTime;
  final String? gatewayReference;
  final double? refundAmount;
  final String? refundReason;
  final DateTime? refundDate;

  const PaymentItem({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userAvatarBg,
    required this.purpose,
    required this.amount,
    required this.paymentMethod,
    required this.transactionId,
    required this.orderId,
    required this.status,
    required this.dateTime,
    this.gatewayReference,
    this.refundAmount,
    this.refundReason,
    this.refundDate,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? 'User',
      userEmail: json['user_email']?.toString() ?? 'user@example.com',
      userAvatarBg: _getAvatarColor(json['user_name']?.toString() ?? ''),
      purpose: PaymentPurpose.fromString(json['purpose']?.toString() ?? 'testSeries'),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      paymentMethod: PaymentMethodType.fromString(json['payment_method']?.toString() ?? 'upi'),
      transactionId: json['transaction_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      status: PaymentStatus.fromString(json['status']?.toString() ?? 'pending'),
      dateTime: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      gatewayReference: json['gateway_ref']?.toString(),
      refundAmount: (json['refund_amount'] is num) ? (json['refund_amount'] as num).toDouble() : null,
      refundReason: json['refund_reason']?.toString(),
      refundDate: json['refund_date'] != null
          ? DateTime.tryParse(json['refund_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user_email': userEmail,
      'purpose': purpose.name,
      'amount': amount,
      'payment_method': paymentMethod.name,
      'transaction_id': transactionId,
      'order_id': orderId,
      'status': status.name,
      'created_at': dateTime.toIso8601String(),
      'gateway_ref': gatewayReference,
      'refund_amount': refundAmount,
      'refund_reason': refundReason,
      'refund_date': refundDate?.toIso8601String(),
    };
  }

  PaymentItem copyWith({
    String? id,
    String? userName,
    String? userEmail,
    Color? userAvatarBg,
    PaymentPurpose? purpose,
    double? amount,
    PaymentMethodType? paymentMethod,
    String? transactionId,
    String? orderId,
    PaymentStatus? status,
    DateTime? dateTime,
    String? gatewayReference,
    double? refundAmount,
    String? refundReason,
    DateTime? refundDate,
  }) {
    return PaymentItem(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userAvatarBg: userAvatarBg ?? this.userAvatarBg,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      gatewayReference: gatewayReference ?? this.gatewayReference,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      refundDate: refundDate ?? this.refundDate,
    );
  }

  static Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6B4EFF),
      const Color(0xFF2587F8),
      const Color(0xFF10B981),
      const Color(0xFFFF9F0A),
      const Color(0xFFF04483),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];
    if (name.isEmpty) return colors[0];
    final idx = name.codeUnits.reduce((a, b) => a + b) % colors.length;
    return colors[idx];
  }
}
