import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_layer/data_layer.dart';

/// Pre-configured Coin Top-up Pack
class CoinPack {
  final int id;
  final int coins;
  final int bonusCoins;
  final double priceRupees;
  final String tag;
  final bool isPopular;
  final Color? accentColor;

  const CoinPack({
    required this.id,
    required this.coins,
    this.bonusCoins = 0,
    required this.priceRupees,
    required this.tag,
    this.isPopular = false,
    this.accentColor,
  });

  int get totalCoins => coins + bonusCoins;
}

const List<CoinPack> kPredefinedCoinPacks = [
  CoinPack(
    id: 1,
    coins: 300,
    bonusCoins: 0,
    priceRupees: 29,
    tag: 'Starter',
  ),
  CoinPack(
    id: 2,
    coins: 600,
    bonusCoins: 100,
    priceRupees: 49,
    tag: 'Most Popular',
    isPopular: true,
    accentColor: Color(0xFF00B96B),
  ),
  CoinPack(
    id: 3,
    coins: 1400,
    bonusCoins: 200,
    priceRupees: 99,
    tag: 'Best Value',
    accentColor: Color(0xFF2587F8),
  ),
  CoinPack(
    id: 4,
    coins: 3000,
    bonusCoins: 800,
    priceRupees: 199,
    tag: 'Pro Gamer',
    accentColor: Color(0xFF8B5CF6),
  ),
  CoinPack(
    id: 5,
    coins: 8000,
    bonusCoins: 2000,
    priceRupees: 499,
    tag: 'Mega Master',
    accentColor: Color(0xFFF59E0B),
  ),
];

/// Premium Modal Bottom Sheet for Buying Coins via UPI / QR
class BuyCoinsModal extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback? onTopUpSubmitted;

  const BuyCoinsModal({
    super.key,
    required this.profile,
    this.onTopUpSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required UserProfile profile,
    VoidCallback? onTopUpSubmitted,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 800;

    if (isDesktop) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580, maxHeight: 750),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BuyCoinsModal(
                profile: profile,
                onTopUpSubmitted: onTopUpSubmitted,
              ),
            ),
          ),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BuyCoinsModal(
            profile: profile,
            onTopUpSubmitted: onTopUpSubmitted,
          ),
        ),
      ),
    );
  }

  @override
  State<BuyCoinsModal> createState() => _BuyCoinsModalState();
}

class _BuyCoinsModalState extends State<BuyCoinsModal> {
  // Step: 1 = Select Pack, 2 = Pay via UPI & Enter UTR, 3 = Success
  int _currentStep = 1;

  CoinPack _selectedPack = kPredefinedCoinPacks[1]; // Default to Popular 700 Coins
  bool _isCustomPack = false;
  final TextEditingController _customAmountCtrl = TextEditingController(text: '100');
  final TextEditingController _utrController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSubmitting = false;
  bool _copiedUpi = false;

  final String _platformUpiId = 'rankearn.pay@icici';
  final String _merchantName = 'Rankearn Technologies';

  @override
  void dispose() {
    _customAmountCtrl.dispose();
    _utrController.dispose();
    super.dispose();
  }

  int get _calculatedCoins {
    if (_isCustomPack) {
      final amt = double.tryParse(_customAmountCtrl.text.trim()) ?? 0;
      return (amt * 10).toInt(); // 10 coins per rupee base
    }
    return _selectedPack.totalCoins;
  }

  double get _payableAmount {
    if (_isCustomPack) {
      return double.tryParse(_customAmountCtrl.text.trim()) ?? 0;
    }
    return _selectedPack.priceRupees;
  }

  void _copyUpiId() {
    Clipboard.setData(ClipboardData(text: _platformUpiId));
    setState(() => _copiedUpi = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiedUpi = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UPI ID copied to clipboard! Open your UPI app to pay.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitTopUp() async {
    if (!_formKey.currentState!.validate()) return;

    final utr = _utrController.text.trim().toUpperCase();
    final coins = _calculatedCoins;
    final amount = _payableAmount;

    setState(() => _isSubmitting = true);

    final repo = WalletRepository();
    final res = await repo.submitTopUpRequest(
      userId: widget.profile.id,
      amount: amount,
      coinsAwarded: coins,
      utr: utr,
      userName: widget.profile.name.isEmpty ? 'Student Candidate' : widget.profile.name,
      userEmail: widget.profile.email.isEmpty ? 'candidate@rankearn.in' : widget.profile.email,
      userPhone: widget.profile.phone,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (res) {
      case Success():
        setState(() => _currentStep = 3);
        widget.onTopUpSubmitted?.call();
      case Failure(message: final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text(msg),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Drag handle for modal
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFF59E0B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentStep == 1
                            ? 'Buy Coins / Top-up'
                            : (_currentStep == 2 ? 'Complete Payment' : 'Top-up Submitted'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101A3A),
                        ),
                      ),
                      Text(
                        _currentStep == 1
                            ? 'Choose a coin pack to unlock premium tests'
                            : (_currentStep == 2 ? 'Pay via UPI and enter reference number' : 'Request sent for admin verification'),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Modal Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              physics: const BouncingScrollPhysics(),
              child: switch (_currentStep) {
                1 => _buildPackSelectionStep(),
                2 => _buildPaymentVerificationStep(),
                _ => _buildSuccessStep(),
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 1: PACK SELECTION
  // ==========================================
  Widget _buildPackSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live User Balance Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFC928),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${widget.profile.coins} Coins',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10194F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAF2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '10 Coins ≈ ₹1',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF008C52)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Select Coin Pack',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
        ),
        const SizedBox(height: 10),

        // Predefined Coin Packs Grid
        ...kPredefinedCoinPacks.map((pack) {
          final isSelected = !_isCustomPack && _selectedPack.id == pack.id;
          return _buildCoinPackCard(pack, isSelected);
        }),

        const SizedBox(height: 14),

        // Custom Amount Toggle
        InkWell(
          onTap: () => setState(() => _isCustomPack = true),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCustomPack ? const Color(0xFFF5F3FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCustomPack ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0),
                width: _isCustomPack ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isCustomPack ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: _isCustomPack ? const Color(0xFF8B5CF6) : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Enter Custom Amount (₹)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF101A3A)),
                      ),
                    ),
                    if (_isCustomPack)
                      Text(
                        '= $_calculatedCoins Coins',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8B5CF6)),
                      ),
                  ],
                ),
                if (_isCustomPack) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _customAmountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      hintText: 'Enter amount (min ₹10)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Continue Button
        ElevatedButton(
          onPressed: () {
            if (_payableAmount < 10) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Minimum deposit amount is ₹10.')),
              );
              return;
            }
            setState(() => _currentStep = 2);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B96B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Buy $_calculatedCoins Coins for ₹${_payableAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoinPackCard(CoinPack pack, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() {
          _isCustomPack = false;
          _selectedPack = pack;
        }),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? const Color(0xFF00B96B) : const Color(0xFF94A3B8),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${pack.totalCoins} Coins',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF101A3A),
                          ),
                        ),
                        if (pack.bonusCoins > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Text(
                              '+${pack.bonusCoins} Bonus',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pack.tag,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: pack.accentColor ?? const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF00B96B) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  '₹${pack.priceRupees.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF101A3A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: PAYMENT & UTR SUBMISSION
  // ==========================================
  Widget _buildPaymentVerificationStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10194F), Color(0xFF1B2A78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You are buying',
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFC928), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$_calculatedCoins Coins',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B96B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Pay ₹${_payableAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Step 1: Transfer via UPI
          const Text(
            'Step 1: Pay via UPI to Official ID',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Rankearn UPI ID',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _platformUpiId,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10194F),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Verified: $_merchantName',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00B96B),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _copyUpiId,
                      icon: Icon(_copiedUpi ? Icons.check_rounded : Icons.copy_rounded, size: 14),
                      label: Text(_copiedUpi ? 'Copied' : 'Copy ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _copiedUpi ? const Color(0xFF00B96B) : const Color(0xFF2587F8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Merchant: Rankearn Technologies • Supported: GPay, PhonePe, Paytm, BHIM',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Step 2: Enter 12-digit UTR
          const Text(
            'Step 2: Enter Transaction Reference / UTR',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF101A3A)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _utrController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'e.g. 430129847120 (12 digits)',
              prefixIcon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF00B96B), width: 2),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().length < 6) {
                return 'Please enter a valid UPI reference number / UTR';
              }
              return null;
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'ℹ️ You can find the 12-digit UPI Transaction ID / UTR in your payment app under receipt details.',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),

          // Actions
          Row(
            children: [
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitTopUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B96B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Submit Payment Request',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3: SUCCESS STATE
  // ==========================================
  Widget _buildSuccessStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Color(0xFFE8FAF2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF00B96B),
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Top-up Request Submitted!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF10194F),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your request for $_calculatedCoins Coins (₹${_payableAmount.toStringAsFixed(0)}) with UTR "${_utrController.text.trim().toUpperCase()}" has been recorded.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.timer_outlined, color: Color(0xFF2587F8), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Verification takes 2–5 minutes. Coins will reflect in your wallet balance automatically once approved by the admin.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10194F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Back to Wallet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
