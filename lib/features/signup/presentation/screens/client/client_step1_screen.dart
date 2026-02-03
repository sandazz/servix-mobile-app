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

/// Client signup step 1 - Personal/Business Information
class ClientStep1Screen extends ConsumerStatefulWidget {
  const ClientStep1Screen({super.key});

  @override
  ConsumerState<ClientStep1Screen> createState() => _ClientStep1ScreenState();
}

class _ClientStep1ScreenState extends ConsumerState<ClientStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _positionController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    _firstNameController = TextEditingController(text: signupData.firstName);
    _lastNameController = TextEditingController(text: signupData.lastName);
    _emailController = TextEditingController(text: signupData.email);
    _companyNameController = TextEditingController(
      text: signupData.companyName ?? '',
    );
    _positionController = TextEditingController(
      text: signupData.userPosition ?? '',
    );
    _addressController = TextEditingController(text: signupData.address);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;

    final signupData = ref.read(signupProvider);
    final isBusiness = signupData.clientType == ClientType.business;

    ref
        .read(signupProvider.notifier)
        .updatePersonalInfo(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          address: isBusiness ? _addressController.text.trim() : '',
          companyName: _companyNameController.text.trim(),
          userPosition: _positionController.text.trim(),
        );

    context.go('/signup-steps/step2');
  }

  @override
  Widget build(BuildContext context) {
    final signupData = ref.watch(signupProvider);
    final isBusiness = signupData.clientType == ClientType.business;

    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-select-account'),
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
            Text(
              isBusiness ? 'Business Information' : 'Personal Information',
              style: const TextStyle(
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
                        if (isBusiness) ...[
                          // Company Name
                          CustomTextField(
                            label: 'Company Name *',
                            hint: 'Enter your company name',
                            controller: _companyNameController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.business),
                            validator: (value) => Validators.validateRequired(
                              value,
                              'Company name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Position
                          CustomTextField(
                            label: 'Your Position *',
                            hint: 'e.g., Manager, Director',
                            controller: _positionController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.badge),
                            validator: (value) =>
                                Validators.validateRequired(value, 'Position'),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!isBusiness) ...[
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
                        ],
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
                        if (isBusiness) ...[
                          // Business Address
                          CustomTextField(
                            label: 'Business Address *',
                            hint: 'Enter your address',
                            controller: _addressController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            validator: (value) =>
                                Validators.validateRequired(value, 'Address'),
                          ),
                        ],
                        if (!isBusiness) ...[
                          const SizedBox(height: 16),
                          // Optional Company Name for personal accounts
                          CustomTextField(
                            label: 'Company Name (Optional)',
                            hint: 'Enter company name if applicable',
                            controller: _companyNameController,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.business_outlined),
                          ),
                        ],
                        const SizedBox(height: 32),
                        // Next Button
                        PrimaryButton(text: 'Next', onPressed: _handleNext),

                        const SizedBox(height: 20),
                        const StepIndicator(currentStep: 1, totalSteps: 5),
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
