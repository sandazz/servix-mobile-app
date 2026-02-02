import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:servix/core/config/app_config.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/services/api/api_exception.dart';
import 'package:servix/data/models/auth_models.dart';
import 'package:servix/data/repositories/auth_repository.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';

/// Client signup step 3 - OTP Verification
class ClientStep3Screen extends ConsumerStatefulWidget {
  const ClientStep3Screen({super.key});

  @override
  ConsumerState<ClientStep3Screen> createState() => _ClientStep3ScreenState();
}

class _ClientStep3ScreenState extends ConsumerState<ClientStep3Screen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = AppConfig.otpResendTimeout;
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Pre-fill OTP if available from server response
    final signupData = ref.read(signupProvider);
    if (signupData.otp.isNotEmpty) {
      _otpController.text = signupData.otp;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = AppConfig.otpResendTimeout;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != AppConfig.otpLength) {
      setState(() {
        _errorMessage =
            'Please enter the complete ${AppConfig.otpLength}-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final signupData = ref.read(signupProvider);
      final repository = ref.read(authRepositoryProvider);

      await repository.verifyOtp(
        VerifyOtpRequest(userId: signupData.userId!, otp: otp),
      );

      if (mounted) {
        context.go('/signup-steps/step4');
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResend() async {
    if (_secondsRemaining > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final signupData = ref.read(signupProvider);
      final repository = ref.read(authRepositoryProvider);

      await repository.resendOtp(ResendOtpRequest(userId: signupData.userId!));
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupData = ref.watch(signupProvider);
    final maskedPhone = _maskPhoneNumber(signupData.mobileNumber);

    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-steps/step2'),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 3, totalSteps: 5),
            const SizedBox(height: 20),
            // Header
            const Text(
              'Verify Your Phone',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the code sent to $maskedPhone',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 30),
            // OTP Input
            Expanded(
              child: WhiteRoundedContainer(
                child: Column(
                  children: [
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
                    // OTP Pin Code Fields
                    PinCodeTextField(
                      appContext: context,
                      length: AppConfig.otpLength,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 56,
                        fieldWidth: 48,
                        activeFillColor: AppColors.white,
                        inactiveFillColor: AppColors.grey100,
                        selectedFillColor: AppColors.white,
                        activeColor: AppColors.primaryBlue,
                        inactiveColor: AppColors.grey300,
                        selectedColor: AppColors.primaryBlue,
                      ),
                      enableActiveFill: true,
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      onCompleted: (value) {
                        _handleVerify();
                      },
                    ),
                    const SizedBox(height: 24),
                    // Resend Timer
                    if (_secondsRemaining > 0)
                      Text(
                        'Resend code in ${_secondsRemaining}s',
                        style: const TextStyle(
                          color: AppColors.grey600,
                          fontSize: 14,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _isResending ? null : _handleResend,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend Code',
                          style: TextStyle(
                            color: _isResending
                                ? AppColors.grey500
                                : AppColors.primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Verify Button
                    PrimaryButton(
                      text: 'Verify',
                      onPressed: _handleVerify,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length < 6) return phone;
    final visible = phone.substring(phone.length - 4);
    return '****$visible';
  }
}
