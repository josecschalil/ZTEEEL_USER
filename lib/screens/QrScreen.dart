import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/redemption_service.dart';
import 'RecentOrderScreen.dart';

class RedeemColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const backgroundDark = Color(0xFF221510);
  static const surfaceDark = Color(0xFF332019);
  static const timerBoxDark = Color(0xFF482C23);
  static const mutedTextDark = Color(0xFFC9A092);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
  );
}

typedef QrScreen = RedeemQrScreen;

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class RedeemQrScreen extends StatefulWidget {
  final RedemptionSessionData? session;
  final String? qrCode;
  final bool openedFromOrdersScreen;

  const RedeemQrScreen({
    super.key,
    this.session,
    this.qrCode,
    this.openedFromOrdersScreen = false,
  });

  @override
  State<RedeemQrScreen> createState() => _RedeemQrScreenState();
}

class _RedeemQrScreenState extends State<RedeemQrScreen> {
  RedemptionSessionData? _session;
  bool _isLoading = false;
  Duration _remaining = const Duration(minutes: 5);
  Timer? _ticker;
  Timer? _statusPoller;
  bool _hasTriggeredCompletion = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    if (_session != null) {
      _initTimer();
      if (_session!.isConfirmed) {
        _onOrderCompletedDetected();
      } else {
        _startStatusPolling();
      }
    } else {
      _loadSession();
    }
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    if (widget.qrCode != null && widget.qrCode!.isNotEmpty) {
      final res = await RedemptionService.getQRDetail(widget.qrCode!);
      if (mounted) {
        setState(() {
          _session = res;
          _isLoading = false;
        });
        if (res != null) {
          _initTimer();
          if (res.isConfirmed) {
            _onOrderCompletedDetected();
          } else {
            _startStatusPolling();
          }
        }
      }
    } else {
      final list = await RedemptionService.getCustomerRedemptions();
      if (mounted) {
        setState(() {
          _session = list.isNotEmpty ? list.first : null;
          _isLoading = false;
        });
        if (_session != null) {
          _initTimer();
          if (_session!.isConfirmed) {
            _onOrderCompletedDetected();
          } else {
            _startStatusPolling();
          }
        }
      }
    }
  }

  void _onOrderCompletedDetected() {
    if (_hasTriggeredCompletion) return;
    _hasTriggeredCompletion = true;
    _statusPoller?.cancel();
    _ticker?.cancel();
    if (!mounted) return;

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order verified & marked as completed!'),
        backgroundColor: RedeemColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (widget.openedFromOrdersScreen && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OrdersScreen(initialTabIndex: 1),
          ),
        );
      }
    });
  }

  void _initTimer() {
    _ticker?.cancel();
    if (_session?.expiresAt != null) {
      final now = DateTime.now();
      final diff = _session!.expiresAt!.difference(now);
      _remaining = diff.isNegative ? Duration.zero : diff;
    } else {
      _remaining = const Duration(minutes: 5);
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining -= const Duration(seconds: 1);
        } else {
          _ticker?.cancel();
        }
      });
    });
  }

  void _startStatusPolling() {
    _statusPoller?.cancel();
    if (_session == null || !_session!.isPending) return;

    _statusPoller = Timer.periodic(const Duration(milliseconds: 1500), (_) async {
      if (!mounted || _session == null || !_session!.isPending) {
        _statusPoller?.cancel();
        return;
      }
      final updated = await RedemptionService.getQRDetail(_session!.qrCode);
      if (mounted && updated != null) {
        if (updated.status.toLowerCase() != _session!.status.toLowerCase() ||
            updated.isConfirmed != _session!.isConfirmed ||
            updated.isExpired != _session!.isExpired) {
          setState(() {
            _session = updated;
          });
          if (updated.isConfirmed) {
            _onOrderCompletedDetected();
          } else if (!updated.isPending) {
            _statusPoller?.cancel();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _statusPoller?.cancel();
    super.dispose();
  }

  void _showExpandQrModal(BuildContext context, String qrData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _session?.vendor?.businessName ?? 'Scan QR Code',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 260,
                height: 260,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 260.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1E1714),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1E1714),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Order #${qrData.replaceAll('-', '').substring(0, qrData.replaceAll('-', '').length >= 8 ? 8 : qrData.replaceAll('-', '').length).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C5751),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedeemColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? RedeemColors.backgroundDark : RedeemColors.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(color: RedeemColors.primary),
        ),
      );
    }

    final session = _session;
    final qrData = session?.qrCode ?? 'C571267D';
    final cleanQr = qrData.replaceAll('-', '').toUpperCase();
    final shortOrderId = cleanQr.length >= 8 ? cleanQr.substring(0, 8) : cleanQr;

    return Scaffold(
      backgroundColor: isDark ? RedeemColors.backgroundDark : RedeemColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: RefreshIndicator(
                color: RedeemColors.primary,
                onRefresh: _loadSession,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  _QrCard(
                    isDark: isDark,
                    qrData: qrData,
                    orderId: 'Order #$shortOrderId',
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                    status: session?.status ?? 'pending',
                    vendorName: session?.vendor?.businessName,
                    onExpand: () => _showExpandQrModal(context, qrData),
                  ),
                  const SizedBox(height: 24),
                  _OrderSummary(
                    isDark: isDark,
                    items: session?.items ?? const [],
                  ),
                  const SizedBox(height: 16),
                  _TotalCard(
                    subtotal: session?.subtotal ?? 0.0,
                    discount: session?.totalDiscount ?? 0.0,
                    total: session?.finalTotal ?? 0.0,
                    discountLabel: session != null && session.totalDiscount > 0
                        ? '${((session.totalDiscount / (session.subtotal > 0 ? session.subtotal : 1)) * 100).toInt()}% OFF'
                        : 'Savings Applied',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
            _BottomActionBar(
              isDark: isDark,
              onDone: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: (isDark ? RedeemColors.backgroundDark : RedeemColors.backgroundLight)
          .withValues(alpha: 0.95),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Redeem Deal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Help',
                style: TextStyle(
                  color: RedeemColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// QR code card
/// ---------------------------------------------------------------------
class _QrCard extends StatelessWidget {
  final bool isDark;
  final String qrData;
  final String orderId;
  final String hours;
  final String minutes;
  final String seconds;
  final String status;
  final String? vendorName;
  final VoidCallback onExpand;

  const _QrCard({
    required this.isDark,
    required this.qrData,
    required this.orderId,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.status,
    this.vendorName,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmed = status == 'confirmed' || status == 'completed';
    final isExpired = status == 'expired' || status == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? RedeemColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          if (vendorName != null && vendorName!.isNotEmpty) ...[
            Text(
              vendorName!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF332019),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isConfirmed
                    ? const Color(0xFF10B981)
                    : (isExpired ? Colors.red.shade300 : const Color(0xFFEEEEEE)),
                width: 2,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1E1714),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1E1714),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            orderId,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          if (isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Order Verified & Redeemed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            )
          else if (isExpired)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                status.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            )
          else
            _CompactTimerChip(
              isDark: isDark,
              hours: hours,
              minutes: minutes,
              seconds: seconds,
            ),
          const SizedBox(height: 14),
          Text(
            isConfirmed
                ? 'Your order has been verified by the restaurant counter.'
                : 'Show this QR code to the cashier at the counter to verify and redeem your deal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? RedeemColors.mutedTextDark : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onExpand,
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                Icons.fullscreen,
                color: isDark ? Colors.white : Colors.black87,
              ),
              label: Text(
                'Expand Code',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Compact countdown chip
/// ---------------------------------------------------------------------
class _CompactTimerChip extends StatelessWidget {
  final bool isDark;
  final String hours;
  final String minutes;
  final String seconds;
  const _CompactTimerChip({
    required this.isDark,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? RedeemColors.timerBoxDark
            : RedeemColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: isDark
            ? null
            : Border.all(color: RedeemColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 13,
            color: isDark ? Colors.white : RedeemColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Expires in ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? RedeemColors.mutedTextDark : Colors.grey[600],
            ),
          ),
          Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : RedeemColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Order summary card
/// ---------------------------------------------------------------------
class _OrderSummary extends StatelessWidget {
  final bool isDark;
  final List<RedemptionItem> items;

  const _OrderSummary({
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? RedeemColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _OrderLineRow(isDark: isDark, item: items[i]),
                if (i != items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      height: 1,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey[100],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderLineRow extends StatelessWidget {
  final bool isDark;
  final RedemptionItem item;
  const _OrderLineRow({required this.isDark, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 64,
            height: 64,
            color: isDark ? const Color(0xFF482C23) : const Color(0xFFF3F4F6),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.restaurant_rounded,
                      color: RedeemColors.primary,
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.restaurant_rounded,
                    color: RedeemColors.primary,
                    size: 28,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    item.isRewardItem
                        ? 'FREE'
                        : '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: item.isRewardItem ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? RedeemColors.mutedTextDark : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Qty: ${item.quantity}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Total / discount card
/// ---------------------------------------------------------------------
class _TotalCard extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final String discountLabel;

  const _TotalCard({
    required this.subtotal,
    required this.discount,
    required this.total,
    this.discountLabel = 'Savings Applied',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RedeemColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: RedeemColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount ($discountLabel)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Colors.white24),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total to Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed bottom action bar: Share Deal / Done
/// ---------------------------------------------------------------------
class _BottomActionBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onDone;

  const _BottomActionBar({
    required this.isDark,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? RedeemColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[200]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.share,
                  color: isDark ? Colors.white : Colors.black,
                ),
                label: Text(
                  'Share Deal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black87,
                  foregroundColor: isDark
                      ? RedeemColors.backgroundDark
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
