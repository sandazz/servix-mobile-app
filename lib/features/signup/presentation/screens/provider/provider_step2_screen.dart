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
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 2, totalSteps: 6),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Services & Security',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
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
                          'Service Categories *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select the services you offer',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Service Categories Grid
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ServiceCategory.values.map((category) {
                            final isSelected = _selectedCategories.contains(
                              category.key,
                            );
                            return FilterChip(
                              label: Text(category.displayName),
                              selected: isSelected,
                              onSelected: (_) => _toggleCategory(category.key),
                              selectedColor: AppColors.primaryBlue.withOpacity(
                                0.2,
                              ),
                              checkmarkColor: AppColors.primaryBlue,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.grey700,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : AppColors.grey300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Address
                        CustomTextField(
                          label: 'Service Area / Address *',
                          hint: 'Enter your service area',
                          controller: _addressController,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          validator: (value) =>
                              Validators.validateRequired(value, 'Address'),
                        ),
                        const SizedBox(height: 16),
                        // Password
                        PasswordTextField(
                          label: 'Password *',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Password must be at least 8 characters with uppercase, lowercase, number, and special character',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
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
                        const SizedBox(height: 32),
                        // Next Button
                        PrimaryButton(text: 'Next', onPressed: _handleNext),
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
