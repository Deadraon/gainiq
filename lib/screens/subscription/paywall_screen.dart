import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/subscription_model.dart';
import '../../core/providers/subscription_provider.dart';
import '../../core/services/coupon_service.dart';
import '../../core/services/mymobpay_service.dart';
import 'mymobpay_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  SubscriptionPlan _selected = SubscriptionPlan.pro;
  bool _isPurchasing = false;

  // Coupon state
  bool _showCouponField = false;
  final _couponController = TextEditingController();
  bool _isRedeeming = false;
  String? _couponError;
  String? _couponSuccess;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    // Step 1 – Show confirm sheet
    final confirmed = await _showPaymentConfirmSheet();
    if (!confirmed || !mounted) return;

    setState(() => _isPurchasing = true);

    final subProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    final userId = subProvider.currentUserId ??
        'guest_${DateTime.now().millisecondsSinceEpoch}';
    final amount = _selected == SubscriptionPlan.pro ? 199.0 : 299.0;
    final planLabel =
        _selected == SubscriptionPlan.pro ? 'Pro ⚡' : 'Advance 👑';

    // Step 2 – Fetch MyMobPay order details from secure Vercel API
    final orderResponse = await MyMobPayService.generateOrder(
      amount: amount,
      customerId: userId,
      planName: _selected.name,
      customerPhone: subProvider.currentUserPhone,
      customerName: subProvider.currentUserEmail,
    );

    if (!mounted) return;

    if (!orderResponse.success) {
      setState(() => _isPurchasing = false);
      _showError(orderResponse.errorMessage ?? 'Could not initiate payment.');
      return;
    }

    setState(() => _isPurchasing = false);

    if (kIsWeb) {
      // ── Web Flow: Open in new tab and poll status ──
      final paymentUrl = MyMobPayService.buildPaymentUrl(
        orderId: orderResponse.orderId!,
        amount: orderResponse.orderAmount!,
        apiKey: orderResponse.apiKey!,
        callbackUrl: 'https://gainiq-ten.vercel.app/api/mymobpay-callback',
      );
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          _waitForWebPayment(orderResponse.orderId!, planLabel);
        }
      } else {
        _showError('Could not open payment window.');
      }
    } else {
      // ── Mobile Flow: Launch Paytm/MyMobPay WebView checkout ──
      final result = await Navigator.of(context).push<MyMobPayResult>(
        MaterialPageRoute(
          builder: (_) => MyMobPayWebViewScreen(
            orderId: orderResponse.orderId!,
            amount: orderResponse.orderAmount!,
            apiKey: orderResponse.apiKey!,
          ),
          fullscreenDialog: true,
        ),
      );

      if (!mounted) return;

      if (result == null) return; // WebView closed without result

      // Handle mobile result
      switch (result.status) {
        case MyMobPayStatus.success:
          final success = await subProvider.activatePlan(_selected);
          if (mounted) {
            success
                ? _showSuccessDialog(planLabel)
                : _showError(
                    'Payment received but activation failed. Contact support.');
          }
          break;
        case MyMobPayStatus.failed:
          _showError(result.message ?? 'Payment failed. Please try again.');
          break;
        case MyMobPayStatus.cancelled:
          break; // User backed out — no action
        case MyMobPayStatus.pending:
          _showPendingSnackbar(result.orderId ?? '');
          break;
      }
    }
  }

  Future<bool> _showPaymentConfirmSheet() async {
    final amount = _selected == SubscriptionPlan.pro ? '₹199' : '₹299';
    final planName = _selected == SubscriptionPlan.pro ? 'Pro ⚡' : 'Advance 👑';

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // UPI Icon
                  child: const Text('⚡', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pay via UPI',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 17)),
                    Text('Google Pay · PhonePe · Paytm · BHIM',
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A1A1A)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$planName Plan',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13)),
                  Text(amount,
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Billed monthly · Cancel anytime',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 11),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // Indigo Blue
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔒 ', style: TextStyle(fontSize: 14)),
                    Text('Continue to Pay $amount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 13)),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }

  void _showPendingSnackbar(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 5),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Pending',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Text(
              'Your payment is being verified. Order: $orderId',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redeemCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = 'Please enter a coupon code.');
      return;
    }

    setState(() {
      _isRedeeming = true;
      _couponError = null;
      _couponSuccess = null;
    });

    final (result, coupon) = await CouponService.redeemCoupon(code);

    if (!mounted) return;
    setState(() => _isRedeeming = false);

    switch (result) {
      case CouponRedeemResult.success:
        // Activate the subscription using coupon plan + duration
        final subProvider =
            Provider.of<SubscriptionProvider>(context, listen: false);
        await subProvider.activatePlanWithDuration(
          coupon!.subscriptionPlan,
          coupon.durationDays,
        );
        if (mounted) {
          _showSuccessDialog(
              '${coupon.planEmoji} ${coupon.planName} (${coupon.durationDays} days)');
        }
        break;
      case CouponRedeemResult.notFound:
        setState(() => _couponError = 'Coupon not found. Check your code.');
        break;
      case CouponRedeemResult.expired:
        setState(() => _couponError = 'This coupon has expired.');
        break;
      case CouponRedeemResult.exhausted:
        setState(() => _couponError = 'This coupon has no uses remaining.');
        break;
      case CouponRedeemResult.alreadyUsed:
        setState(() => _couponError = 'You have already used this coupon.');
        break;
      case CouponRedeemResult.inactive:
        setState(() => _couponError = 'This coupon is no longer active.');
        break;
      case CouponRedeemResult.error:
        setState(
            () => _couponError = 'Something went wrong. Please try again.');
        break;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessDialog(String planLabel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFE5FF00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.black, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Premium!',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your $planLabel plan is now active.',
              style:
                  TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5FF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Start Training',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1C1C00), Color(0xFF0A0A0A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: Theme.of(context).iconTheme.color),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5FF00),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text('⚡',
                                    style: TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Upgrade GainIQ',
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyLarge?.color,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold)),
                                  Text('Unlock your full potential',
                                      style: TextStyle(
                                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _featureRow(Icons.auto_awesome_rounded,
                              'AI-powered diet & workout plans'),
                          const SizedBox(height: 10),
                          _featureRow(Icons.bar_chart_rounded,
                              'Advanced progress analytics'),
                          const SizedBox(height: 10),
                          _featureRow(
                              Icons.support_agent_rounded, 'Priority support'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Choose Your Plan',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Plan cards
                  _PlanCard(
                    plan: SubscriptionPlan.pro,
                    emoji: '⚡',
                    name: 'Pro',
                    price: 199,
                    period: '/month',
                    color: const Color(0xFF3D8BFF),
                    features: const [
                      'AI Diet Plan Generator',
                      'Unlimited Workout Plans',
                      'Progress Tracking',
                      'Streak Analytics',
                      'Priority Email Support',
                    ],
                    isSelected: _selected == SubscriptionPlan.pro,
                    onTap: () =>
                        setState(() => _selected = SubscriptionPlan.pro),
                  ),
                  const SizedBox(height: 16),
                  _PlanCard(
                    plan: SubscriptionPlan.advance,
                    emoji: '👑',
                    name: 'Advance',
                    price: 299,
                    period: '/month',
                    color: const Color(0xFFE5FF00),
                    features: const [
                      'Everything in Pro',
                      'Custom AI Meal Planning',
                      'Advanced Body Composition',
                      'Personalized Coach AI',
                      '1-on-1 Chat Support',
                    ],
                    isSelected: _selected == SubscriptionPlan.advance,
                    badge: 'BEST VALUE',
                    onTap: () =>
                        setState(() => _selected = SubscriptionPlan.advance),
                  ),
                  const SizedBox(height: 28),

                  // ── Subscribe Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : _purchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5FF00),
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            const Color(0xFFE5FF00).withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5))
                          : Text(
                              'Subscribe ${_selected == SubscriptionPlan.pro ? '• ₹199/mo' : '• ₹299/mo'}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Cancel anytime · Auto-renews monthly · No hidden fees',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Coupon Section ──────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.07)),
                    ),
                    child: Column(
                      children: [
                        // Toggle row
                        InkWell(
                          onTap: () => setState(() {
                            _showCouponField = !_showCouponField;
                            _couponError = null;
                            _couponSuccess = null;
                          }),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5FF00)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.local_offer_rounded,
                                      color: Color(0xFFE5FF00),
                                      size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text('Have a coupon code?',
                                    style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14)),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _showCouponField ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 250),
                                  child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Theme.of(context).iconTheme.color?.withOpacity(0.38),
                                      size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expandable coupon input
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: _showCouponField
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: Colors.white10, height: 1),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _couponController,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          hintText: 'ENTER CODE',
                                          hintStyle: TextStyle(
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.2),
                                              letterSpacing: 2,
                                              fontSize: 13),
                                          filled: true,
                                          fillColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.black.withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 14, vertical: 12),
                                          prefixIcon: Icon(
                                              Icons.confirmation_number_rounded,
                                              color: Theme.of(context).iconTheme.color?.withOpacity(0.38),
                                              size: 18),
                                        ),
                                        onChanged: (_) => setState(() {
                                          _couponError = null;
                                        }),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: _isRedeeming
                                          ? null
                                          : _redeemCoupon,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFE5FF00),
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 18, vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: _isRedeeming
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                  color: Colors.black,
                                                  strokeWidth: 2))
                                          : const Text('Apply',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                if (_couponError != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: Colors.redAccent, size: 14),
                                      const SizedBox(width: 6),
                                      Text(_couponError!,
                                          style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                                if (_couponSuccess != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: Colors.greenAccent, size: 14),
                                      const SizedBox(width: 6),
                                      Text(_couponSuccess!,
                                          style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: const Color(0xFFE5FF00), size: 18),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
        ],
      );

  Future<void> _waitForWebPayment(String orderId, String planLabel) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _WebPaymentPendingDialog(
          orderId: orderId,
          plan: _selected,
          planLabel: planLabel,
          onSuccess: () {
            Navigator.of(dialogContext).pop();
            _showSuccessDialog(planLabel);
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}

// ── Plan Card ────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final String emoji;
  final String name;
  final int price;
  final String period;
  final Color color;
  final List<String> features;
  final bool isSelected;
  final String? badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.emoji,
    required this.name,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color:
              isSelected ? color.withOpacity(0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor.withOpacity(0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(name,
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(badge!,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5)),
                            ),
                          ],
                        ],
                      ),
                      Text('Billed monthly',
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹$price',
                          style: TextStyle(
                              color: color,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Text(period,
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 14),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: color, size: 16),
                        const SizedBox(width: 10),
                        Text(f,
                            style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
                      ],
                    ),
                  )),
              if (isSelected)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.radio_button_checked_rounded,
                            color: color, size: 14),
                        const SizedBox(width: 4),
                        Text('Selected',
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebPaymentPendingDialog extends StatefulWidget {
  final String orderId;
  final SubscriptionPlan plan;
  final String planLabel;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _WebPaymentPendingDialog({
    required this.orderId,
    required this.plan,
    required this.planLabel,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_WebPaymentPendingDialog> createState() => _WebPaymentPendingDialogState();
}

class _WebPaymentPendingDialogState extends State<_WebPaymentPendingDialog> {
  Timer? _pollingTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Poll order status every 3 seconds to detect payment completion on Web
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final status = await MyMobPayService.getOrderStatus(widget.orderId);
      if (!mounted) return;

      if (status == 'verified') {
        _pollingTimer?.cancel();
        // Activate subscription on the client-side immediately
        final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
        await subProvider.activatePlan(widget.plan);
        widget.onSuccess();
      } else if (status == 'expired' || status == 'rejected') {
        _pollingTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment status: $status'), backgroundColor: Colors.redAccent),
        );
        widget.onCancel();
      }
    } catch (e) {
      debugPrint('Web status check error: $e');
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Text('💳 ', style: TextStyle(fontSize: 22)),
          Text(
            'Payment Pending',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFFE5FF00)),
          SizedBox(height: 20),
          Text(
            'We opened the payment screen in a new browser tab.\n\nPlease complete the payment there. Once paid, your subscription will activate automatically.',
            style: TextStyle(fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(
            'Cancel Payment',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
