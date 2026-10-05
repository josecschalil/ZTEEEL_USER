import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../services/auth_service.dart';
import 'dashboard.dart';

/// Collects the only details required to complete a customer account.
class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  bool _isSaving = false;
  String? _error;

  bool get _isComplete =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_onChanged);
    _lastNameController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() => _error = null);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    if (!_isComplete || _isSaving) {
      setState(() => _error = 'Please enter both your first and last name.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });
    final result = await AuthService.updateCustomerProfile(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result['success'] == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeDiscoveryScreen()),
        (_) => false,
      );
      return;
    }

    final message = result['error']?.toString() ??
        'Unable to save your details. Please try again.';
    setState(() => _error = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.orangeDim,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        resizeToAvoidBottomInset: true,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: fade,
                      child: SlideTransition(
                        position: slide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                IconButton(
                                  key: const Key('name_back_button'),
                                  onPressed: _isSaving
                                      ? null
                                      : () => Navigator.maybePop(context),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(42, 42),
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Text('Zteel', style: theme.textTheme.titleMedium?.copyWith(letterSpacing: -.4)),
                              ],
                            ),
                            const SizedBox(height: 64),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'STEP 3 OF 3',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.orange,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Let’s make it\npersonal.',
                              style: AppTypography.textTheme.displayLarge?.copyWith(fontSize: 40),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Tell us what to call you when we find your next great meal.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 42),
                            _NameField(
                              fieldKey: const Key('first_name_field'),
                              label: 'FIRST NAME',
                              hint: 'Enter your first name',
                              controller: _firstNameController,
                              focusNode: _firstNameFocus,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.givenName],
                              onSubmitted: (_) => _lastNameFocus.requestFocus(),
                            ),
                            const SizedBox(height: 24),
                            _NameField(
                              fieldKey: const Key('last_name_field'),
                              label: 'LAST NAME',
                              hint: 'Enter your last name',
                              controller: _lastNameController,
                              focusNode: _lastNameFocus,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.familyName],
                              onSubmitted: (_) => _continue(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.orangeDim)),
                            ],
                            const Spacer(),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.only(top: 16, bottom: 24),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: AppColors.border)),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  key: const Key('name_continue_button'),
                                  onPressed: _isSaving || !_isComplete ? null : _continue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: AppColors.textWhite,
                                    disabledBackgroundColor: AppColors.border,
                                    disabledForegroundColor: AppColors.textSecondary,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2.4),
                                        )
                                      : const Text('Continue'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    super.key,
    required this.fieldKey,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.textInputAction,
    required this.autofillHints,
    required this.onSubmitted,
  });

  final String label;
  final Key fieldKey;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 1.25)),
        const SizedBox(height: 10),
        TextField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          maxLength: 150,
          onSubmitted: onSubmitted,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
