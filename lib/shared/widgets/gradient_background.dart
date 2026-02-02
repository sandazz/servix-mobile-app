import 'package:flutter/material.dart';
import 'package:servix/core/constants/app_colors.dart';

/// Primary gradient background with curved overlay
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const GradientBackground({
    super.key,
    required this.child,
    this.showLogo = true,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with optional back button and logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (showBackButton)
                    IconButton(
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.white,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  if (showLogo)
                    const Text(
                      'SERVIX',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Main content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// White rounded container that appears above the gradient
class WhiteRoundedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const WhiteRoundedContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

/// Curved overlay layout for signup screens
class CurvedOverlayLayout extends StatelessWidget {
  final Widget topContent;
  final Widget bottomContent;
  final double topHeight;

  const CurvedOverlayLayout({
    super.key,
    required this.topContent,
    required this.bottomContent,
    this.topHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: topHeight,
          child: Center(child: topContent),
        ),
        Expanded(child: WhiteRoundedContainer(child: bottomContent)),
      ],
    );
  }
}
