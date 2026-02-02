import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/config/app_config.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/core/services/api/api_exception.dart';
import 'package:servix/core/utils/validators.dart';
import 'package:servix/data/models/auth_models.dart';
import 'package:servix/data/repositories/auth_repository.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';
import 'package:servix/shared/widgets/text_fields.dart';

/// Client signup step 2 - Contact & Password
class ClientStep2Screen extends ConsumerStatefulWidget {
  const ClientStep2Screen({super.key});

  @override
  ConsumerState<ClientStep2Screen> createState() => _ClientStep2ScreenState();
}

class _ClientStep2ScreenState extends ConsumerState<ClientStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  late final TextEditingController _secondaryPhoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    // Remove country code prefix if present for display
    String phone = signupData.mobileNumber;
    if (phone.startsWith('+61')) {
      phone = phone.substring(3);
    }
    _phoneController = TextEditingController(text: phone);

    String secondaryPhone = signupData.secondaryPhoneNumber ?? '';
    if (secondaryPhone.startsWith('+61')) {
      secondaryPhone = secondaryPhone.substring(3);
    }
    _secondaryPhoneController = TextEditingController(text: secondaryPhone);
    _passwordController = TextEditingController(text: signupData.password);
    _confirmPasswordController = TextEditingController(
      text: signupData.confirmPassword,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Format phone number with country code
    final phoneNumber =
        '${AppConfig.phonePrefix}${_phoneController.text.trim()}';
    final secondaryPhone = _secondaryPhoneController.text.trim().isNotEmpty
        ? '${AppConfig.phonePrefix}${_secondaryPhoneController.text.trim()}'
        : null;

    // Update signup data
    ref
        .read(signupProvider.notifier)
        .updateContactInfo(
          mobileNumber: phoneNumber,
          secondaryPhoneNumber: secondaryPhone,
        );
    ref
        .read(signupProvider.notifier)
        .updatePassword(
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );

    try {
      // Get the complete signup data
      final signupData = ref.read(signupProvider);

      // Create registration request
      final request = RegisterClientRequest(
        clientType: signupData.clientType?.key ?? 'PERSONAL',
        firstName: signupData.firstName,
        lastName: signupData.lastName,
        email: signupData.email,
        phoneNumber: phoneNumber,
        password: _passwordController.text,
        address: signupData.address,
        companyName: signupData.companyName,
        userPosition: signupData.userPosition,
        secondaryPhoneNumber: secondaryPhone,
      );

      // Register the client
      final repository = ref.read(authRepositoryProvider);
      final response = await repository.registerClient(request);

      // Update signup data with user ID and OTP
      ref.read(signupProvider.notifier).setUserId(response.userId);
      if (response.otp != null) {
        ref.read(signupProvider.notifier).setOtp(response.otp!);
      }

      if (mounted) {
        context.go('/signup-steps/step3');
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupData = ref.watch(signupProvider);
    final isBusiness = signupData.clientType == ClientType.business;

    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-steps/step1'),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 2, totalSteps: 5),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Contact & Security',
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
                        // Error Message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
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
                        const SizedBox(height: 16),
                        // Secondary Phone (Business only)
                        if (isBusiness) ...[
                          PhoneTextField(
                            label: 'Secondary Phone Number',
                            hint: '412 345 679',
                            controller: _secondaryPhoneController,
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Password
                        PasswordTextField(
                          label: 'Password *',
                          hint: 'Create a strong password',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 8),
                        // Password requirements hint
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
                        PrimaryButton(
                          text: 'Create Account',
                          onPressed: _handleNext,
                          isLoading: _isLoading,
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
