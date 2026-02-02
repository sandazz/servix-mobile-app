import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:servix/core/constants/app_colors.dart';

/// Bookings screen - view and manage bookings
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.grey900,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.primaryBlue,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingsList(status: 'upcoming'),
            _BookingsList(status: 'completed'),
            _BookingsList(status: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final String status;

  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual bookings data
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _BookingCard(
          serviceName: 'Service ${index + 1}',
          providerName: 'Provider Name',
          date: 'Dec ${15 + index}, 2024',
          time: '${10 + index}:00 AM',
          status: status,
          price: '\$${50 + index * 25}.00',
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String serviceName;
  final String providerName;
  final String date;
  final String time;
  final String status;
  final String price;

  const _BookingCard({
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'upcoming':
        return AppColors.primaryBlue;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by $providerName',
                        style: TextStyle(
                          color: AppColors.grey500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.grey600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$date at $time',
                      style: TextStyle(color: AppColors.grey700, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
