import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/common_app_bar.dart';
import '../controller/my_booking_controller.dart';

class MyBookingPage extends GetView<MyBookingController> {
  const MyBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: const CommonAppBar(
        title: 'My Bookings',
        showBack: true,
        showLanguageToggle: true,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookings.isEmpty) {
          return const Center(child: Text('No bookings found'));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchBookings,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [


              ...controller.bookings.map((booking) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.serviceName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(booking.status),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(booking.details),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text('${booking.address}, ${booking.city}'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),

                          const SizedBox(width: 6),

                          Text('${booking.date} • ${booking.time}'),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Budget: ৳${booking.maxLimit}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
