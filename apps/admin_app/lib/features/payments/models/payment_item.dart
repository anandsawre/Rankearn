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

  static final List<PaymentItem> referenceMockItems = [
    PaymentItem(
      id: 'pay-1',
      userName: 'Rahul Sharma',
      userEmail: 'rahul.sharma@example.com',
      userAvatarBg: const Color(0xFF2587F8),
      purpose: PaymentPurpose.testSeries,
      amount: 199.0,
      paymentMethod: PaymentMethodType.razorpay,
      transactionId: 'pay_7H3kLm92',
      orderId: 'ord_9842104',
      status: PaymentStatus.success,
      dateTime: DateTime(2026, 10, 18, 10, 24),
      gatewayReference: 'rzp_capt_789123',
    ),
    PaymentItem(
      id: 'pay-2',
      userName: 'Priya Verma',
      userEmail: 'priya.verma@example.com',
      userAvatarBg: const Color(0xFFF04483),
      purpose: PaymentPurpose.liveQuiz,
      amount: 49.0,
      paymentMethod: PaymentMethodType.upi,
      transactionId: 'upi_8J9nPq33',
      orderId: 'ord_9842105',
      status: PaymentStatus.success,
      dateTime: DateTime(2026, 10, 18, 9, 12),
      gatewayReference: 'upi_ref_441299',
    ),
    PaymentItem(
      id: 'pay-3',
      userName: 'Amit Kumar',
      userEmail: 'amit.kumar@example.com',
      userAvatarBg: const Color(0xFF10B981),
      purpose: PaymentPurpose.tournament,
      amount: 299.0,
      paymentMethod: PaymentMethodType.creditCard,
      transactionId: 'card_9X2mKp11',
      orderId: 'ord_9842106',
      status: PaymentStatus.success,
      dateTime: DateTime(2026, 10, 17, 20, 45),
      gatewayReference: 'hdfc_pg_662310',
    ),
    PaymentItem(
      id: 'pay-4',
      userName: 'Neha Singh',
      userEmail: 'neha.singh@example.com',
      userAvatarBg: const Color(0xFFFF9F0A),
      purpose: PaymentPurpose.subscription,
      amount: 499.0,
      paymentMethod: PaymentMethodType.netBanking,
      transactionId: 'nb_2LmNq88',
      orderId: 'ord_9842107',
      status: PaymentStatus.success,
      dateTime: DateTime(2026, 10, 17, 18, 30),
      gatewayReference: 'sbi_nb_990142',
    ),
    PaymentItem(
      id: 'pay-5',
      userName: 'Vikash Yadav',
      userEmail: 'vikash.yadav@example.com',
      userAvatarBg: const Color(0xFF6B4EFF),
      purpose: PaymentPurpose.testSeries,
      amount: 149.0,
      paymentMethod: PaymentMethodType.upi,
      transactionId: 'upi_6K8pZj22',
      orderId: 'ord_9842108',
      status: PaymentStatus.failed,
      dateTime: DateTime(2026, 10, 16, 17, 20),
      gatewayReference: 'upi_fail_timeout',
    ),
    PaymentItem(
      id: 'pay-6',
      userName: 'Anjali Patel',
      userEmail: 'anjali.patel@example.com',
      userAvatarBg: const Color(0xFF06B6D4),
      purpose: PaymentPurpose.tournament,
      amount: 299.0,
      paymentMethod: PaymentMethodType.wallet,
      transactionId: 'wal_4MNQx77',
      orderId: 'ord_9842109',
      status: PaymentStatus.success,
      dateTime: DateTime(2026, 10, 16, 16, 10),
      gatewayReference: 'paytm_wal_88231',
    ),
    PaymentItem(
      id: 'pay-7',
      userName: 'Saurabh Gupta',
      userEmail: 'saurabh.gupta@example.com',
      userAvatarBg: const Color(0xFF8B5CF6),
      purpose: PaymentPurpose.liveQuiz,
      amount: 99.0,
      paymentMethod: PaymentMethodType.debitCard,
      transactionId: 'card_3LpNW55',
      orderId: 'ord_9842110',
      status: PaymentStatus.pending,
      dateTime: DateTime(2026, 10, 15, 14, 15),
      gatewayReference: 'axis_deb_awaiting_webhook',
    ),
  ];
}
