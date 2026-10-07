import '../app_colors.dart';
import 'package:flutter/material.dart';


/// ---------------------------------------------------------------------
/// Data model
/// ---------------------------------------------------------------------
enum NotifType { order, promo, reward, account }

class NotifIconStyle {
  final IconData icon;
  final Color color;
  const NotifIconStyle(this.icon, this.color);
}

const _typeStyles = {
  NotifType.order: NotifIconStyle(Icons.receipt_long, AppColors.toneFF3B82F6),
  NotifType.promo: NotifIconStyle(
    Icons.local_fire_department,
    AppColors.primary,
  ),
  NotifType.reward: NotifIconStyle(Icons.card_giftcard, AppColors.vegGreen),
  NotifType.account: NotifIconStyle(Icons.person, AppColors.toneFFA855F7),
};

class NotifItem {
  final String id;
  final NotifType type;
  final String title;
  final String message;
  final String time;
  bool read;
  NotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.read = false,
  });
}

class NotifSection {
  final String label;
  final List<NotifItem> items;
  NotifSection({required this.label, required this.items});
}

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotifSection> _sections = [
    NotifSection(
      label: 'Today',
      items: [
        NotifItem(
          id: 'n1',
          type: NotifType.order,
          title: 'Order confirmed',
          message: 'Your order #C571267D at The Golden Spoon is being prepared.',
          time: '2m ago',
        ),
        NotifItem(
          id: 'n2',
          type: NotifType.promo,
          title: 'Flash deal near you 🔥',
          message: '50% off all Pasta dishes at The Golden Spoon, ends soon.',
          time: '1h ago',
        ),
        NotifItem(
          id: 'n3',
          type: NotifType.reward,
          title: 'Almost there!',
          message: "Spend \$11.50 more this week to unlock a FREE item.",
          time: '3h ago',
          read: true,
        ),
      ],
    ),
    NotifSection(
      label: 'Yesterday',
      items: [
        NotifItem(
          id: 'n4',
          type: NotifType.order,
          title: 'Order delivered',
          message: 'Your order from Urban Bites & Co. was delivered. Enjoy!',
          time: '1d ago',
          read: true,
        ),
        NotifItem(
          id: 'n5',
          type: NotifType.account,
          title: 'Profile updated',
          message: 'Your phone number was changed successfully.',
          time: '1d ago',
          read: true,
        ),
      ],
    ),
    NotifSection(
      label: 'This Week',
      items: [
        NotifItem(
          id: 'n6',
          type: NotifType.reward,
          title: "You're now a Gold Member!",
          message: 'Enjoy exclusive discounts and priority offers.',
          time: '4d ago',
          read: true,
        ),
        NotifItem(
          id: 'n7',
          type: NotifType.promo,
          title: 'New restaurant added',
          message: 'The Smokehouse just joined ZTEEEL — 20% off this week.',
          time: '6d ago',
          read: true,
        ),
      ],
    ),
  ];

  int get _unreadCount =>
      _sections.expand((s) => s.items).where((i) => !i.read).length;

  void _markAllRead() {
    setState(() {
      for (final section in _sections) {
        for (final item in section.items) {
          item.read = true;
        }
      }
    });
  }

  void _dismiss(NotifSection section, NotifItem item) {
    setState(() => section.items.remove(item));
  }

  void _toggleRead(NotifItem item) {
    setState(() => item.read = true);
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAny = _sections.any((s) => s.items.isNotEmpty);
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              isDark: isDark,
              unreadCount: _unreadCount,
              onMarkAllRead: _markAllRead,
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
                onRefresh: _refreshNotifications,
                child: hasAny
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          for (final section in _sections)
                            if (section.items.isNotEmpty)
                              _NotifSectionWidget(
                                isDark: isDark,
                                section: section,
                                onDismiss: (item) => _dismiss(section, item),
                                onTap: _toggleRead,
                              ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        children: [
                          _EmptyState(isDark: isDark),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  const _Header({
    required this.isDark,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: textColor,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 38,
            height: 38,
            child: unreadCount > 0
                ? IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onMarkAllRead,
                    icon: const Icon(
                      Icons.done_all,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    tooltip: 'Mark all as read',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Section: label + list of notification cards
/// ---------------------------------------------------------------------
class _NotifSectionWidget extends StatelessWidget {
  final bool isDark;
  final NotifSection section;
  final ValueChanged<NotifItem> onDismiss;
  final ValueChanged<NotifItem> onTap;
  const _NotifSectionWidget({
    required this.isDark,
    required this.section,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = isDark
        ? AppColors.white.withValues(alpha: 0.4)
        : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
          child: Text(
            section.label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 1.6,
            ),
          ),
        ),
        ...section.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey(item.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => onDismiss(item),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.materialRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.materialRedAccent,
                ),
              ),
              child: _NotifCard(
                isDark: isDark,
                item: item,
                onTap: () => onTap(item),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// A single notification card
/// ---------------------------------------------------------------------
class _NotifCard extends StatelessWidget {
  final bool isDark;
  final NotifItem item;
  final VoidCallback onTap;
  const _NotifCard({
    required this.isDark,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = _typeStyles[item.type]!;
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final titleColor = isDark ? AppColors.white : AppColors.textPrimary;
    final messageColor = isDark
        ? AppColors.white.withValues(alpha: 0.6)
        : AppColors.textMuted;
    final timeColor = isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight;
    final borderColor = item.read
        ? (isDark
            ? AppColors.white.withValues(alpha: 0.05)
            : AppColors.borderLight)
        : AppColors.primary.withValues(alpha: 0.25);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, color: style.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (!item.read)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: messageColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Empty state
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subtextColor = isDark
        ? AppColors.white.withValues(alpha: 0.5)
        : AppColors.textMuted;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You're all caught up",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'New deals, order updates, and rewards will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: subtextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
