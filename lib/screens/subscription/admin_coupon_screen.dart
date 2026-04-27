import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/models/coupon_model.dart';
import '../../core/services/coupon_service.dart';

class AdminCouponScreen extends StatefulWidget {
  const AdminCouponScreen({super.key});

  @override
  State<AdminCouponScreen> createState() => _AdminCouponScreenState();
}

class _AdminCouponScreenState extends State<AdminCouponScreen>
    with SingleTickerProviderStateMixin {
  List<CouponModel> _coupons = [];
  bool _isLoading = true;

  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadCoupons();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadCoupons() async {
    setState(() => _isLoading = true);
    final list = await CouponService.listCoupons();
    if (mounted) setState(() { _coupons = list; _isLoading = false; });
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateCouponSheet(onCreated: _loadCoupons),
    );
  }

  Future<void> _toggleCoupon(CouponModel c) async {
    await CouponService.toggleCoupon(c.code, !c.isActive);
    _loadCoupons();
  }

  Future<void> _deleteCoupon(CouponModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Coupon', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${c.code}"? This cannot be undone.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await CouponService.deleteCoupon(c.code);
      _loadCoupons();
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _coupons.where((c) => c.isActive && !c.isExpired && !c.isExhausted).toList();
    final inactive = _coupons.where((c) => !c.isActive || c.isExpired || c.isExhausted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        title: const Text('Coupon Manager',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: _loadCoupons,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFE5FF00),
          labelColor: const Color(0xFFE5FF00),
          unselectedLabelColor: Colors.white38,
          tabs: [
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Inactive (${inactive.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFFE5FF00),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Coupon',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE5FF00)))
          : TabBarView(
              controller: _tabs,
              children: [
                _CouponList(
                  coupons: active,
                  emptyMessage: 'No active coupons.\nTap + to create one.',
                  onToggle: _toggleCoupon,
                  onDelete: _deleteCoupon,
                ),
                _CouponList(
                  coupons: inactive,
                  emptyMessage: 'No inactive coupons.',
                  onToggle: _toggleCoupon,
                  onDelete: _deleteCoupon,
                ),
              ],
            ),
    );
  }
}

// ── Coupon List ─────────────────────────────────────────────
class _CouponList extends StatelessWidget {
  final List<CouponModel> coupons;
  final String emptyMessage;
  final Future<void> Function(CouponModel) onToggle;
  final Future<void> Function(CouponModel) onDelete;

  const _CouponList({
    required this.coupons,
    required this.emptyMessage,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (coupons.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 14)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: coupons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CouponCard(
          coupon: coupons[i], onToggle: onToggle, onDelete: onDelete),
    );
  }
}

// ── Coupon Card ─────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final Future<void> Function(CouponModel) onToggle;
  final Future<void> Function(CouponModel) onDelete;

  const _CouponCard(
      {required this.coupon, required this.onToggle, required this.onDelete});

  Color get _planColor =>
      coupon.plan == CouponPlan.advance
          ? const Color(0xFFE5FF00)
          : const Color(0xFF3D8BFF);

  @override
  Widget build(BuildContext context) {
    final expiry = coupon.expiresAt != null
        ? DateFormat('dd MMM yyyy').format(coupon.expiresAt!)
        : 'No expiry';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: coupon.canRedeem
              ? _planColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Code chip
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: coupon.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Code copied to clipboard!'),
                          duration: Duration(seconds: 1)),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _planColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _planColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          coupon.code,
                          style: TextStyle(
                            color: _planColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.copy_rounded, color: _planColor, size: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Plan badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _planColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${coupon.planEmoji} ${coupon.planName}',
                    style: TextStyle(
                      color: coupon.plan == CouponPlan.advance
                          ? Colors.black
                          : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                // Status dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: coupon.canRedeem ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
            if (coupon.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(coupon.description,
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            // Stats row
            Row(
              children: [
                _stat(Icons.people_rounded, '${coupon.usedCount}/${coupon.maxUses}', 'Uses'),
                const SizedBox(width: 20),
                _stat(Icons.calendar_today_rounded, expiry, 'Expires'),
                const SizedBox(width: 20),
                _stat(Icons.timer_rounded, '${coupon.durationDays}d', 'Duration'),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onToggle(coupon),
                    icon: Icon(
                        coupon.isActive
                            ? Icons.pause_circle_rounded
                            : Icons.play_circle_rounded,
                        size: 16),
                    label: Text(coupon.isActive ? 'Deactivate' : 'Activate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          coupon.isActive ? Colors.orange : Colors.greenAccent,
                      side: BorderSide(
                          color: coupon.isActive
                              ? Colors.orange.withOpacity(0.4)
                              : Colors.greenAccent.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () => onDelete(coupon),
                  icon: const Icon(Icons.delete_rounded,
                      color: Colors.redAccent, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white38, size: 12),
              const SizedBox(width: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      );
}

// ── Create Coupon Bottom Sheet ──────────────────────────────
class _CreateCouponSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const _CreateCouponSheet({required this.onCreated});

  @override
  State<_CreateCouponSheet> createState() => _CreateCouponSheetState();
}

class _CreateCouponSheetState extends State<_CreateCouponSheet> {
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  CouponPlan _plan = CouponPlan.pro;
  int _maxUses = 1;
  int _durationDays = 30;
  DateTime? _expiresAt;
  bool _isCreating = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    final prefix = _plan == CouponPlan.advance ? 'ADV' : 'PRO';
    final suffix = rand.toString().substring(rand.toString().length - 4);
    return '$prefix-$suffix';
  }

  Future<void> _create() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code.')),
      );
      return;
    }

    setState(() => _isCreating = true);

    final coupon = CouponModel(
      code: code,
      plan: _plan,
      durationDays: _durationDays,
      maxUses: _maxUses,
      expiresAt: _expiresAt,
      createdAt: DateTime.now(),
      description: _descCtrl.text.trim(),
    );

    final success = await CouponService.createCoupon(coupon);

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (success) {
      widget.onCreated();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon "$code" created!'),
          backgroundColor: Colors.greenAccent.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to create coupon. Try again.'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Create Coupon',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Code field
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _codeCtrl,
                    label: 'Coupon Code',
                    hint: 'e.g. GAINIQ50',
                    caps: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => setState(
                      () => _codeCtrl.text = _generateCode()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: const Color(0xFFE5FF00),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description
            _field(
              controller: _descCtrl,
              label: 'Description (optional)',
              hint: 'e.g. Gift for new user',
            ),
            const SizedBox(height: 14),

            // Plan selector
            _label('Plan'),
            const SizedBox(height: 8),
            Row(
              children: [
                _planChip('⚡ Pro', CouponPlan.pro, const Color(0xFF3D8BFF)),
                const SizedBox(width: 10),
                _planChip('👑 Advance', CouponPlan.advance, const Color(0xFFE5FF00)),
              ],
            ),
            const SizedBox(height: 16),

            // Duration
            _label('Duration: $_durationDays days'),
            Slider(
              value: _durationDays.toDouble(),
              min: 1,
              max: 365,
              divisions: 72,
              activeColor: const Color(0xFFE5FF00),
              inactiveColor: Colors.white12,
              onChanged: (v) => setState(() => _durationDays = v.round()),
            ),
            const SizedBox(height: 8),

            // Max uses
            _label('Max Uses: $_maxUses'),
            Slider(
              value: _maxUses.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              activeColor: const Color(0xFF3D8BFF),
              inactiveColor: Colors.white12,
              onChanged: (v) => setState(() => _maxUses = v.round()),
            ),
            const SizedBox(height: 8),

            // Expiry date
            _label('Expiry Date'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFFE5FF00),
                        onPrimary: Colors.black,
                        surface: Color(0xFF1A1A1A),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _expiresAt = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white38, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      _expiresAt != null
                          ? DateFormat('dd MMM yyyy').format(_expiresAt!)
                          : 'No expiry (unlimited)',
                      style: TextStyle(
                          color: _expiresAt != null
                              ? Colors.white
                              : Colors.white38,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    if (_expiresAt != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiresAt = null),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white38, size: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5FF00),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.black, strokeWidth: 2))
                    : const Text('Create Coupon',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextCapitalization caps = TextCapitalization.none,
  }) =>
      TextField(
        controller: controller,
        textCapitalization: caps,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500));

  Widget _planChip(String label, CouponPlan p, Color color) {
    final sel = _plan == p;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _plan = p),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? color.withOpacity(0.12) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel ? color : Colors.white12,
                width: sel ? 1.5 : 1),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: sel ? color : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
