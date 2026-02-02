import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';
import 'package:servix/shared/widgets/step_indicator.dart';

/// Client signup step 5 - Verification Success
class ClientStep5Screen extends ConsumerWidget {
  const ClientStep5Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const StepIndicator(currentStep: 5, totalSteps: 5),
            const SizedBox(height: 40),
            // Success Animation
            Expanded(
              child: WhiteRoundedContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      'Verification Complete!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Your account has been verified successfully. You can now start using Servix.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Continue Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: PrimaryButton(
                        text: 'Continue',
                        onPressed: () =>
                            context.go('/signup-steps/congratulation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
