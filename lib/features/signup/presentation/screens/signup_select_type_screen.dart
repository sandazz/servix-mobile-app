import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';

/// Screen for selecting user type (Service Provider or Client)
class SignupSelectTypeScreen extends ConsumerStatefulWidget {
  const SignupSelectTypeScreen({super.key});

  @override
  ConsumerState<SignupSelectTypeScreen> createState() =>
      _SignupSelectTypeScreenState();
}

class _SignupSelectTypeScreenState
    extends ConsumerState<SignupSelectTypeScreen> {
  UserType? _selectedType;

  void _handleContinue() {
    if (_selectedType == null) return;

    ref.read(signupProvider.notifier).setUserType(_selectedType!);
    ref.read(signupProvider.notifier).clearServerErrors();

    if (_selectedType == UserType.serviceProvider) {
      context.go('/provider-signup/step1');
    } else {
      context.go('/signup-select-account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
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
              'Select user type',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 40),
            // Selection Cards
            Expanded(
              child: WhiteRoundedContainer(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Service Provider Option
                    SelectionCard(
                      title: 'Service Provider',
                      subtitle:
                          'If you select this option, you can access our services, but you can\'t service provide.',
                      imagePath:
                          'assets/images/user_types/service-providers-user-type.png',
                      isSelected: _selectedType == UserType.serviceProvider,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.serviceProvider;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Client Option
                    SelectionCard(
                      title: 'Contractor',
                      subtitle:
                          'If you select this option, you can provide services, but you can\'t get services from this account.',
                      imagePath:
                          'assets/images/user_types/contractor-user-type.png',
                      isSelected: _selectedType == UserType.contractor,
                      onTap: () {
                        setState(() {
                          _selectedType = UserType.contractor;
                        });
                      },
                    ),
                    const Spacer(),
                    // Continue Button
                    PrimaryButton(
                      text: 'Next',
                      onPressed: _selectedType != null ? _handleContinue : null,
                      isEnabled: _selectedType != null,
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
}
