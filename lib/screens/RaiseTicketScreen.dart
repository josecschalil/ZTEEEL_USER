import 'package:flutter/material.dart';

// ── Local palette (self-contained, no external color file) ─────────────
abstract final class _C {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF7F5F3);
  static const Color orange = Color(0xFFEF5A4C);
  static const Color orangeDim = Color(0x1AEF5A4C);
  static const Color orangeBorder = Color(0x40EF5A4C);
  static const Color green = Color(0xFF1D9E6B);
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF5C5751);
  static const Color textMuted = Color(0xFF8C8680);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFECEAE7);
}

class RaiseTicketScreen extends StatefulWidget {
  const RaiseTicketScreen({super.key});

  @override
  State<RaiseTicketScreen> createState() => _RaiseTicketScreenState();
}

class _RaiseTicketScreenState extends State<RaiseTicketScreen> {
  static const List<String> _categories = [
    'Bug Report',
    'Account Issue',
    'Payment Issue',
    'Feature Request',
    'Other',
  ];
  static const List<String> _priorities = ['Low', 'Medium', 'High'];

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = _categories.first;
  String _selectedPriority = _priorities.first;
  bool _attachmentAdded = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _subjectController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _C.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: _C.textOnAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ticket Submitted',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our team will get back to you shortly. You can track '
                'progress from the Help & Support page.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _C.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pop(); // back to Help & Support
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.orange,
                    foregroundColor: _C.textOnAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                    _buildLabel('Category'),
                    const SizedBox(height: 10),
                    _buildCategoryChips(),
                    const SizedBox(height: 22),
                    _buildLabel('Priority'),
                    const SizedBox(height: 10),
                    _buildPriorityChips(),
                    const SizedBox(height: 22),
                    _buildLabel('Subject'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _subjectController,
                      hint: 'A short summary of the issue',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 22),
                    _buildLabel('Description'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _descriptionController,
                      hint: 'Tell us what happened, steps to reproduce, etc.',
                      maxLines: 6,
                    ),
                    const SizedBox(height: 16),
                    _buildAttachmentRow(),
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raise a Ticket',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Sent straight to the app development team.',
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

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _C.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((c) {
        final selected = c == _selectedCategory;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? _C.orange : _C.surfaceRaised,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: selected ? _C.orange : _C.border),
            ),
            child: Text(
              c,
              style: TextStyle(
                color: selected ? _C.textOnAccent : _C.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriorityChips() {
    return Row(
      children: _priorities.map((p) {
        final selected = p == _selectedPriority;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? _C.orangeDim : _C.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? _C.orangeBorder : _C.border,
                ),
              ),
              child: Text(
                p,
                style: TextStyle(
                  color: selected ? _C.orange : _C.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: _C.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _C.textMuted, fontSize: 12),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAttachmentRow() {
    return GestureDetector(
      onTap: () => setState(() => _attachmentAdded = !_attachmentAdded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _attachmentAdded ? _C.orangeDim : _C.surfaceRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _attachmentAdded ? _C.orangeBorder : _C.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _attachmentAdded
                  ? Icons.check_circle_rounded
                  : Icons.attach_file_rounded,
              color: _attachmentAdded ? _C.orange : _C.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              _attachmentAdded
                  ? 'Screenshot attached'
                  : 'Attach a screenshot (optional)',
              style: TextStyle(
                color: _attachmentAdded ? _C.orange : _C.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canSubmit ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _C.orange,
          disabledBackgroundColor: _C.border,
          foregroundColor: _C.textOnAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Submit Ticket',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
