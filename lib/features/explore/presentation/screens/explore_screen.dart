import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servix/core/constants/app_colors.dart';
import 'package:servix/core/constants/app_constants.dart';

/// Explore screen - service discovery
class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const ExploreScreen({super.key, this.initialCategory});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Services'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services or providers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                ),
                filled: true,
                fillColor: AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search
              },
            ),
          ),
          // Category Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
                ...ServiceCategory.values.map(
                  (category) => _FilterChip(
                    label: category.displayName,
                    isSelected: _selectedCategory == category.key,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category.key;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildResults() {
    // TODO: Replace with actual data from API
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _ProviderCard(
          name: 'Service Provider ${index + 1}',
          category: ServiceCategory
              .values[index % ServiceCategory.values.length]
              .displayName,
          rating: 4.5 + (index % 5) * 0.1,
          reviewCount: 20 + index * 5,
          imageUrl: null,
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Rating',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _RatingFilterChip(rating: 4.5, label: '4.5+'),
                  _RatingFilterChip(rating: 4.0, label: '4.0+'),
                  _RatingFilterChip(rating: 3.5, label: '3.5+'),
                  _RatingFilterChip(rating: 0, label: 'Any'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _DistanceFilterChip(distance: 5, label: '5 km'),
                  _DistanceFilterChip(distance: 10, label: '10 km'),
                  _DistanceFilterChip(distance: 25, label: '25 km'),
                  _DistanceFilterChip(distance: 0, label: 'Any'),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Apply filters
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected
              ? AppColors.primaryBlue
              : AppColors.grey100,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

class _RatingFilterChip extends StatelessWidget {
  final double rating;
  final String label;

  const _RatingFilterChip({required this.rating, required this.label});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rating > 0) ...[
            const Icon(Icons.star, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: false,
      onSelected: (_) {
        // TODO: Implement rating filter
      },
    );
  }
}

class _DistanceFilterChip extends StatelessWidget {
  final int distance;
  final String label;

  const _DistanceFilterChip({required this.distance, required this.label});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (_) {
        // TODO: Implement distance filter
      },
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String? imageUrl;

  const _ProviderCard({
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($reviewCount reviews)',
                  style: TextStyle(color: AppColors.grey500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Available',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          // TODO: Navigate to provider detail
        },
      ),
    );
  }
}
