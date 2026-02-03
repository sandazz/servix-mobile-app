import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
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

/// Client signup step 4 - ABN Verification
class ClientStep4Screen extends ConsumerStatefulWidget {
  const ClientStep4Screen({super.key});

  @override
  ConsumerState<ClientStep4Screen> createState() => _ClientStep4ScreenState();
}

class _ClientStep4ScreenState extends ConsumerState<ClientStep4Screen> {
  final _formKey = GlobalKey<FormState>();
  final _abnController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _companyName;

  @override
  void initState() {
    super.initState();
    final signupData = ref.read(signupProvider);
    _abnController.text = signupData.abnNumber;
  }

  @override
  void dispose() {
    _abnController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _companyName = null;
    });

    try {
      final signupData = ref.read(signupProvider);
      final repository = ref.read(authRepositoryProvider);
      final abn = Validators.cleanAbn(_abnController.text);

      final response = await repository.verifyAbn(
        VerifyAbnRequest(userId: signupData.userId!, abn: abn),
      );

      if (response.success) {
        ref.read(signupProvider.notifier).setAbn(abn);
        setState(() {
          _companyName = response.companyName;
        });

        if (mounted) {
          context.go('/signup-steps/step5');
        }
      } else {
        setState(() {
          _errorMessage = response.message;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ABN verification failed. Please try again.';
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
    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-steps/step3'),
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
              'ABN Verification',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Australian Business Number',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
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
                        const SizedBox(height: 16),
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'ABN is required for business transactions in Australia',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                          const SizedBox(height: 24),
                        ],
                        // ABN Input
                        CustomTextField(
                          label: 'ABN (11 digits) *',
                          hint: '12 345 678 901',
                          controller: _abnController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.numbers),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                            _AbnInputFormatter(),
                          ],
                          validator: (value) {
                            final cleaned = value?.replaceAll(' ', '') ?? '';
                            if (cleaned.isEmpty) {
                              return 'ABN is required';
                            }
                            if (cleaned.length != 11) {
                              return 'ABN must be 11 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Company Name (if verified)
                        if (_companyName != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.success.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.success,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'ABN Verified',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Company: $_companyName',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 32),
                        // Verify Button
                        PrimaryButton(
                          text: 'Verify ABN',
                          onPressed: _handleVerify,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        // Skip for now (optional)
                        TextButton(
                          onPressed: () => context.go('/signup-steps/step5'),
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(color: AppColors.grey600),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const StepIndicator(currentStep: 4, totalSteps: 5),
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

/// Input formatter for ABN (XX XXX XXX XXX format)
class _AbnInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 5 || i == 8) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
