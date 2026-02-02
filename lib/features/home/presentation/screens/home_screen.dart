import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';
import 'package:servix/features/auth/providers/auth_provider.dart';

/// Home screen - main dashboard after login
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      backgroundImage: user?.profileImageUrl != null
                          ? NetworkImage(user!.profileImageUrl!)
                          : null,
                      child: user?.profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user?.fullName ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification Icon
                    IconButton(
                      onPressed: () {
                        // TODO: Navigate to notifications
                      },
                      icon: const Icon(Icons.notifications_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.grey100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    context.go('/explore');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.grey500),
                        const SizedBox(width: 12),
                        Text(
                          'Search for services...',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Service Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go('/explore');
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Service Category Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= ServiceCategory.values.length) return null;
                    final category = ServiceCategory.values[index];
                    return _CategoryCard(category: category);
                  },
                  childCount: ServiceCategory.values.length > 8
                      ? 8
                      : ServiceCategory.values.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // Featured Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Featured Providers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Placeholder for featured providers
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.8),
                            AppColors.primaryDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            top: 20,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Find Your Perfect Service Provider',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Browse verified professionals in your area',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.go('/explore');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Explore Now'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ServiceCategory category;

  const _CategoryCard({required this.category});

  IconData _getCategoryIcon() {
    switch (category) {
      case ServiceCategory.cleaning:
        return Icons.cleaning_services;
      case ServiceCategory.plumbing:
        return Icons.plumbing;
      case ServiceCategory.electrical:
        return Icons.electrical_services;
      case ServiceCategory.carpentry:
        return Icons.carpenter;
      case ServiceCategory.painting:
        return Icons.format_paint;
      case ServiceCategory.gardening:
        return Icons.grass;
      case ServiceCategory.landscaping:
        return Icons.park;
      case ServiceCategory.moving:
        return Icons.local_shipping;
      case ServiceCategory.security:
        return Icons.security;
      case ServiceCategory.hvac:
        return Icons.ac_unit;
      case ServiceCategory.roofing:
        return Icons.roofing;
      case ServiceCategory.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category detail
        context.go('/explore?category=${category.key}');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: AppColors.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.displayName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.grey700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
