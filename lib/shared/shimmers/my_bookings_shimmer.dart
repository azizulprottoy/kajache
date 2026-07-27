import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class MyBookingsShimmer extends StatelessWidget {
  const MyBookingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, __) => const _BookingCardShimmer(),
      ),
    );
  }
}

class _BookingCardShimmer extends StatelessWidget {
  const _BookingCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status accent bar top
          Container(height: 5, decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(children: [
                  const ShimmerBox(width: 46, height: 46, radius: 12),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(width: 100, height: 11, radius: 4),
                    ],
                  )),
                  const SizedBox(width: 8),
                  const ShimmerBox(width: 70, height: 24, radius: 12),
                ]),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.white),
                const SizedBox(height: 14),
                // Location info row
                Row(children: [
                  const ShimmerBox(width: 32, height: 32, radius: 8),
                  const SizedBox(width: 12),
                  const Expanded(child: ShimmerBox(height: 13)),
                ]),
                const SizedBox(height: 10),
                // Date info row
                Row(children: [
                  const ShimmerBox(width: 32, height: 32, radius: 8),
                  const SizedBox(width: 12),
                  const Expanded(child: ShimmerBox(height: 13)),
                ]),
                const SizedBox(height: 16),
                // Summary row
                Row(children: [
                  const Expanded(child: Column(
                    children: [
                      ShimmerBox(width: 24, height: 24, radius: 6),
                      SizedBox(height: 4),
                      ShimmerBox(width: 60, height: 12, radius: 4),
                      SizedBox(height: 2),
                      ShimmerBox(width: 80, height: 11, radius: 4),
                    ],
                  )),
                  Container(width: 1, height: 38, color: Colors.white),
                  const Expanded(child: Column(
                    children: [
                      ShimmerBox(width: 24, height: 24, radius: 6),
                      SizedBox(height: 4),
                      ShimmerBox(width: 60, height: 12, radius: 4),
                      SizedBox(height: 2),
                      ShimmerBox(width: 80, height: 11, radius: 4),
                    ],
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
