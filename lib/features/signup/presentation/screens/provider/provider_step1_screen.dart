import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/utils/validators.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';
import 'package:servix/shared/widgets/text_fields.dart';

/// Provider signup step 1 - Personal Information
class ProviderStep1Screen extends ConsumerStatefulWidget {
  const ProviderStep1Screen({super.key});

  @override
  ConsumerState<ProviderStep1Screen> createState() =>
      _ProviderStep1ScreenState();
}

class _ProviderStep1ScreenState extends ConsumerState<ProviderStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    _firstNameController = TextEditingController(text: signupData.firstName);
    _lastNameController = TextEditingController(text: signupData.lastName);
    _emailController = TextEditingController(text: signupData.email);

    String phone = signupData.mobileNumber;
    if (phone.startsWith('+61')) {
      phone = phone.substring(3);
    }
    _phoneController = TextEditingController(text: phone);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = '+61${_phoneController.text.trim()}';

    ref
        .read(signupProvider.notifier)
        .updatePersonalInfo(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
        );
    ref
        .read(signupProvider.notifier)
        .updateContactInfo(mobileNumber: phoneNumber);

    context.go('/provider-signup/step2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-select-type'),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 1, totalSteps: 6),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Personal Information',
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
                        // First Name
                        CustomTextField(
                          label: 'First Name *',
                          hint: 'Enter your first name',
                          controller: _firstNameController,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) =>
                              Validators.validateName(value, 'First name'),
                        ),
                        const SizedBox(height: 16),
                        // Last Name
                        CustomTextField(
                          label: 'Last Name *',
                          hint: 'Enter your last name',
                          controller: _lastNameController,
                          textCapitalization: TextCapitalization.words,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) =>
                              Validators.validateName(value, 'Last name'),
                        ),
                        const SizedBox(height: 16),
                        // Email
                        CustomTextField(
                          label: 'Email *',
                          hint: 'Enter your email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        // Phone Number
                        PhoneTextField(
                          label: 'Phone Number *',
                          hint: '412 345 678',
                          controller: _phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.length < 9) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
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
