import 'package:flutter/material.dart';
import 'package:servix/core/constants/app_colors.dart';

/// Step indicator widget for signup flows
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSteps,
        (index) => Container(
          width: index + 1 == currentStep ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: index + 1 <= currentStep
                ? AppColors.primaryButton
                : AppColors.grey300,
          ),
        ),
      ),
    );
  }
}
