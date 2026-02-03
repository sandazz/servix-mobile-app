import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/features/signup/providers/signup_provider.dart';
import 'package:servix/shared/widgets/buttons.dart';
import 'package:servix/shared/widgets/gradient_background.dart';

/// Screen for selecting client account type (Personal or Business)
class SignupSelectAccountScreen extends ConsumerStatefulWidget {
  const SignupSelectAccountScreen({super.key});

  @override
  ConsumerState<SignupSelectAccountScreen> createState() =>
      _SignupSelectAccountScreenState();
}

class _SignupSelectAccountScreenState
    extends ConsumerState<SignupSelectAccountScreen> {
  ClientType? _selectedType;

  void _handleContinue() {
    if (_selectedType == null) return;

    ref.read(signupProvider.notifier).setClientType(_selectedType!);
    context.go('/signup-steps/step1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        showBackButton: true,
        onBackPressed: () => context.go('/signup-select-type'),
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
                    // Business Account Option
                    SelectionCard(
                      title: 'Business Account',
                      subtitle: 'If you select this option, you can access our services. but you can\'t service provide.',
                      imagePath:
                          'assets/images/user_types/business-account.png',
                      isSelected: _selectedType == ClientType.business,
                      onTap: () {
                        setState(() {
                          _selectedType = ClientType.business;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Personal Account Option
                    SelectionCard(
                      title: 'Personal Account',
                      subtitle: 'If you select this option, you can provide services. but you can\'t get services from this account.',
                      imagePath:
                          'assets/images/user_types/personal-account.png',
                      isSelected: _selectedType == ClientType.personal,
                      onTap: () {
                        setState(() {
                          _selectedType = ClientType.personal;
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
