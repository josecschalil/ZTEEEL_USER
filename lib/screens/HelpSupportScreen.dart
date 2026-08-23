import 'package:flutter/material.dart';
import 'SupportChatScreen.dart';
import 'RaiseTicketScreen.dart';

// ── Local palette (self-contained, no external color file) ─────────────
abstract final class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF7F5F3);
  static const Color orange = Color(0xFFEF5A4C);
  static const Color orangeDim = Color(0x1AEF5A4C);
  static const Color orangeBorder = Color(0x40EF5A4C);
  static const Color orangeTint = Color(0xFFFDECEA);
  static const Color gold = Color(0xFFC4922E);
  static const Color green = Color(0xFF1D9E6B);
  static const Color greenDim = Color(0x1A1D9E6B);
  static const Color greenBorder = Color(0x401D9E6B);
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF5C5751);
  static const Color textMuted = Color(0xFF8C8680);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECEAE7);
  static const Color black = Colors.black;
}

/// A previously-raised support ticket (mock data — wire up to your backend).
class SupportTicket {
  final String id;
  final String subject;
  final String status; // 'Open' | 'In Progress' | 'Resolved'
  final String date;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.date,
  });
}

/// A single frequently-asked question.
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const List<SupportTicket> _tickets = [
    SupportTicket(
      id: 'TCK-1042',
      subject: 'App crashes when applying a promo code',
      status: 'In Progress',
      date: 'Aug 21, 2026',
    ),
    SupportTicket(
      id: 'TCK-1031',
      subject: 'Unable to reset account password',
      status: 'Resolved',
      date: 'Aug 12, 2026',
    ),
  ];

  static const List<FaqItem> _faqs = [
    FaqItem(
      question: 'Who do I talk to here — the app team or the restaurant?',
      answer:
          'This Help & Support section connects you directly with the app '
          'development team, not any individual restaurant or vendor. For '
          'order-specific questions (missing items, refunds), use the '
          '"Contact Restaurant" option on your order details page instead.',
    ),
    FaqItem(
      question: 'How long does a support ticket take to get a reply?',
      answer:
          'Most tickets receive a first response within 24 hours on '
          'weekdays. You can track the status of your ticket anytime from '
          'the "My Tickets" section above.',
    ),
    FaqItem(
      question: 'Is live chat available 24/7?',
      answer:
          'Live chat is staffed daily from 9 AM to 9 PM. Outside those '
          'hours, messages are queued and answered as soon as the team is '
          'back online.',
    ),
    FaqItem(
      question: 'Can I edit or cancel a ticket after submitting it?',
      answer:
          'Yes — open the ticket from "My Tickets" and use the chat thread '
          'to add details, attach screenshots, or ask to close it.',
    ),
    FaqItem(
      question: 'How do I report a bug with a screenshot?',
      answer:
          'Tap "Raise a Ticket", choose the "Bug Report" category, and use '
          'the attachment option to add a screenshot or screen recording.',
    ),
  ];

  int? _expandedFaqIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    if (_tickets.isNotEmpty) ...[
                      _buildSectionLabel('My Tickets'),
                      const SizedBox(height: 12),
                      _buildTicketsCard(),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionLabel('Frequently Asked Questions'),
                    const SizedBox(height: 12),
                    _buildFaqCard(),
                    const SizedBox(height: 24),
                    _buildFooterCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _C.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _C.orange,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help & Support',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Talk to the app team — not the restaurant.',
                style: TextStyle(
                  color: _C.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: _C.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.chat_bubble_rounded,
            label: 'Live Chat',
            accent: _C.orange,
            accentDim: _C.orangeDim,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SupportChatScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.confirmation_number_rounded,
            label: 'Raise a\nTicket',
            accent: _C.gold,
            accentDim: const Color(0x1AC4922E),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RaiseTicketScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.mail_rounded,
            label: 'Email Us',
            accent: _C.green,
            accentDim: _C.greenDim,
            onTap: () => _showEmailSheet(context),
          ),
        ),
      ],
    );
  }

  void _showEmailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Text(
              'Email the app team',
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'support@appteam.com',
              style: TextStyle(
                color: _C.orange,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'We usually reply within one business day.',
              style: TextStyle(
                color: _C.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Tickets ─────────────────────────────────────────────────────
  Widget _buildTicketsCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: _C.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_tickets.length, (i) {
          final ticket = _tickets[i];
          return Column(
            children: [
              _buildTicketRow(ticket),
              if (i != _tickets.length - 1)
                const Divider(color: _C.border, height: 1),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTicketRow(SupportTicket ticket) {
    final statusColors = _statusColors(ticket.status);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.id,
                  style: const TextStyle(
                    color: _C.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.date,
                  style: const TextStyle(color: _C.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColors.$2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColors.$3),
            ),
            child: Text(
              ticket.status,
              style: TextStyle(
                color: statusColors.$1,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _statusColors(String status) {
    switch (status) {
      case 'Resolved':
        return (_C.green, _C.greenDim, _C.greenBorder);
      case 'In Progress':
        return (_C.gold, const Color(0x1AC4922E), const Color(0x40C4922E));
      default:
        return (_C.orange, _C.orangeDim, _C.orangeBorder);
    }
  }

  // ── FAQ ────────────────────────────────────────────────────────────
  Widget _buildFaqCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: _C.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_faqs.length, (i) {
          final expanded = _expandedFaqIndex == i;
          return Column(
            children: [
              _buildFaqTile(_faqs[i], expanded, () {
                setState(() => _expandedFaqIndex = expanded ? null : i);
              }),
              if (i != _faqs.length - 1)
                const Divider(
                  color: _C.border,
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildFaqTile(FaqItem faq, bool expanded, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    faq.question,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _C.orange,
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  faq.answer,
                  style: const TextStyle(
                    color: _C.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────
  Widget _buildFooterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.orangeTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.orangeBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _C.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _C.textOnAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              "Still stuck? Raise a ticket and our team will follow up directly.",
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable quick-action card ──────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final Color accentDim;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.accent,
    required this.accentDim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _C.border, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: _C.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _C.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
