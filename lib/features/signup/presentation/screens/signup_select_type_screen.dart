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
            const Text(
              'Join Servix',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How would you like to use Servix?',
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
                      subtitle: 'Offer your professional services',
                      icon: Icons.engineering,
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
                      title: 'Client',
                      subtitle: 'Find and hire service providers',
                      icon: Icons.person_search,
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
                      text: 'Continue',
                      onPressed: _selectedType != null ? _handleContinue : null,
                      isEnabled: _selectedType != null,
                    ),
                    const SizedBox(height: 16),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: AppColors.grey600),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
