import 'dart:async';
import 'package:flutter/material.dart';

class RedeemColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const backgroundDark = Color(0xFF221510);
  static const surfaceDark = Color(0xFF332019);
  static const timerBoxDark = Color(0xFF482C23);
  static const mutedTextDark = Color(0xFFC9A092);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
  );
}

/// ---------------------------------------------------------------------
/// Data model
/// ---------------------------------------------------------------------
class OrderLine {
  final String name;
  final String note;
  final int qty;
  final double price;
  final String imageUrl;
  const OrderLine({
    required this.name,
    required this.note,
    required this.qty,
    required this.price,
    required this.imageUrl,
  });
}

const _qrImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCiwAHQDrj0p32lEw2TPch6QPSA02g4Lybd31wSWSOaehf2VggO85ApS4MeSDJyXjaDrBXhIP6YwXQ10hYuC8ESazxkLOXIcocF7_4abWbRKZgCzPfjeafh06j6Lh5Rgyx_UXIoaaCZmALDxaWpbgzr1cLFPL3Ry7U2d7jk6ov-m0KCqtm0bkydSU4XN6Ke8n2gIgHBL0247vAG_YXzpnWFJebSBU330yrem4R_Rl1GhEgiEYYqQEiJ9OxwjZtMv0D5uZeRkMzeeSI_';

const _orderLines = [
  OrderLine(
    name: 'Spicy Tuna Roll Set',
    note: 'Extra spicy mayo, No avocado',
    qty: 2,
    price: 12.00,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBCs0Nd2oMwUr5W2YUnSYTZt8Dg3PnE8JvCszWLfOfkv4icNjJzDp2De8LOxwY2yPxlNtH9Rv469qVczZt7p1Bo2VWrjyZrUvg58OlAdowqrErJLyA5eqBa38Lodnk2cqskLGBjNOOv-zZq3k3i9bjTQR2ET6A-xrnss5TEpK1K1oIu9U2Xmfj7K3MV5P8UOsCmOLBZ8-q3duq_HFvvcMnaEmil_T0kf34nbiRitoJM2y5V9ecnQZKFE-a0zNc7HlQp9JXrHoDwJQEJ',
  ),
  OrderLine(
    name: 'Miso Soup',
    note: 'Hot served',
    qty: 1,
    price: 3.50,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAzVwyx5UJyBlkILUTxyC6woyMOJdGQHNMZcrQZyLzdU1ZwSyW5Jn5OVdi-uUtezcHjo-q5BdB43aCAB44bO4_UQ40vqMg2rUbeDPfRAdks1b6UQermDb6MH5iF0geKrfMudwQBLHCL5NWn_qvRofQtdWGB1L3wLZtFsotLQpa6fXwqYUcbRay34zGjrX0-6whqyIZFqo1R1Wv5IocBTySU6TtrMk2FTmjJrYlB-FqX8aoQZoWN1y6rAJFaFIro74FBs8WaSnT6opxK',
  ),
];

typedef QrScreen = RedeemQrScreen;

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class RedeemQrScreen extends StatefulWidget {
  const RedeemQrScreen({super.key});

  @override
  State<RedeemQrScreen> createState() => _RedeemQrScreenState();
}

class _RedeemQrScreenState extends State<RedeemQrScreen> {
  Duration _remaining = const Duration(hours: 0, minutes: 14, seconds: 59);
  Timer? _ticker;

  static const double _discountRate = 0.20;

  double get _subtotal =>
      _orderLines.fold(0, (sum, l) => sum + l.price * l.qty);
  double get _discount => _subtotal * _discountRate;
  double get _total => _subtotal - _discount;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  _QrCard(
                    isDark: isDark,
                    hours: hours,
                    minutes: minutes,
                    seconds: seconds,
                  ),
                  const SizedBox(height: 24),
                  _OrderSummary(isDark: isDark),
                  const SizedBox(height: 16),
                  _TotalCard(
                    subtotal: _subtotal,
                    discount: _discount,
                    total: _total,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            _BottomActionBar(isDark: isDark),
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
      color:
          (isDark ? RedeemColors.backgroundDark : RedeemColors.backgroundLight)
              .withOpacity(0.95),
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
/// QR code card (now also hosts the compact countdown chip)
/// ---------------------------------------------------------------------
class _QrCard extends StatelessWidget {
  final bool isDark;
  final String hours;
  final String minutes;
  final String seconds;
  const _QrCard({
    required this.isDark,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Opacity(
                opacity: 0.9,
                child: Image.network(_qrImageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order #8492-Z',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          // Compact countdown chip, tucked right under the order number.
          _CompactTimerChip(
            isDark: isDark,
            hours: hours,
            minutes: minutes,
            seconds: seconds,
          ),
          const SizedBox(height: 14),
          Text(
            'Show this QR code to the cashier at the counter to verify and redeem your deal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? RedeemColors.mutedTextDark : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.05)
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
/// Compact countdown chip — small pill with icon + HH:MM:SS
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
            : RedeemColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: isDark
            ? null
            : Border.all(color: RedeemColors.primary.withOpacity(0.2)),
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
  const _OrderSummary({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
              for (int i = 0; i < _orderLines.length; i++) ...[
                _OrderLineRow(isDark: isDark, line: _orderLines[i]),
                if (i != _orderLines.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      height: 1,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
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
  final OrderLine line;
  const _OrderLineRow({required this.isDark, required this.line});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            line.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
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
                      line.name,
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
                    '\$${line.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                line.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? RedeemColors.mutedTextDark : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Qty: ${line.qty}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
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
  const _TotalCard({
    required this.subtotal,
    required this.discount,
    required this.total,
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
            color: RedeemColors.primary.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
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
                'Discount (20% OFF)',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
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
  const _BottomActionBar({required this.isDark});

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
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
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
                        ? Colors.white.withOpacity(0.1)
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
                onPressed: () {},
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
