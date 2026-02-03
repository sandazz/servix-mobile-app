import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/core/utils/validators.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';
import 'package:servix/shared/widgets/text_fields.dart';

/// Provider signup step 2 - Service Categories & Password
class ProviderStep2Screen extends ConsumerStatefulWidget {
  const ProviderStep2Screen({super.key});

  @override
  ConsumerState<ProviderStep2Screen> createState() =>
      _ProviderStep2ScreenState();
}

class _ProviderStep2ScreenState extends ConsumerState<ProviderStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _addressController;
  late Set<String> _selectedCategories;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    _passwordController = TextEditingController(text: signupData.password);
    _confirmPasswordController = TextEditingController(
      text: signupData.confirmPassword,
    );
    _addressController = TextEditingController(text: signupData.address);
    _selectedCategories = Set.from(signupData.serviceCategories);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _showCategorySelector(BuildContext context) {
    setState(() {
      _showDropdown = !_showDropdown;
    });
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref
        .read(signupProvider.notifier)
        .setServiceCategories(_selectedCategories.toList());
    ref
        .read(signupProvider.notifier)
        .updatePassword(
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
    ref
        .read(signupProvider.notifier)
        .updatePersonalInfo(address: _addressController.text.trim());
    ref.read(signupProvider.notifier).setProviderType('PROFESSIONAL');

    context.go('/provider-signup/step3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/provider-signup/step1'),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Image.asset(
              'assets/images/servix-logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            const Text(
              'Services & Security',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 20),
            // Form
            Expanded(
              child: WhiteRoundedContainer(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Service Categories Label
                        const Text(
                          'Job Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Service Categories Dropdown
                        Column(
                          children: [
                            InkWell(
                              onTap: () => _showCategorySelector(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedCategories.isEmpty
                                            ? '(Select Category)'
                                            : _selectedCategories
                                                  .map((key) {
                                                    final category =
                                                        ServiceCategory.values
                                                            .firstWhere(
                                                              (c) =>
                                                                  c.key == key,
                                                            );
                                                    return category.displayName;
                                                  })
                                                  .join(', '),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedCategories.isEmpty
                                              ? AppColors.grey500
                                              : AppColors.grey900,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _showDropdown
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.grey600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showDropdown)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EAF6),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: ServiceCategory.values.length,
                                  itemBuilder: (context, index) {
                                    final category =
                                        ServiceCategory.values[index];
                                    final isSelected = _selectedCategories
                                        .contains(category.key);
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _toggleCategory(category.key);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        color: isSelected
                                            ? const Color(0xFFD1D5F0)
                                            : Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                category.displayName,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: isSelected
                                                      ? const Color(0xFF1E3A8A)
                                                      : AppColors.grey800,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check,
                                                color: Color(0xFF1E3A8A),
                                                size: 20,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Password
                        PasswordTextField(
                          label: 'Password *',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                        ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   'Password must be at least 8 characters with uppercase, lowercase, number, and special character',
                        //   style: TextStyle(
                        //     color: AppColors.grey500,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        const SizedBox(height: 16),
                        // Confirm Password
                        PasswordTextField(
                          label: 'Confirm Password *',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                        ),
                        const SizedBox(height: 16),
                        // Address
                        CustomTextField(
                          label: 'Address *',
                          hint: 'Enter your address',
                          controller: _addressController,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Address'),
                        ),
                        
                        const SizedBox(height: 32),
                        // Next Button
                        PrimaryButton(text: 'Next', onPressed: _handleNext),

                        const SizedBox(height: 20),
                        const StepIndicator(currentStep: 2, totalSteps: 6),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'If you have a account, so',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
