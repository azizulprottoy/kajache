import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class StatisticsShimmer extends StatelessWidget {
  const StatisticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const ShimmerBox(width: 200, height: 24, radius: 6),
          const SizedBox(height: 8),
          const ShimmerBox(height: 14),
          const SizedBox(height: 4),
          const ShimmerBox(width: 260, height: 14),
          const SizedBox(height: 20),
          ...List.generate(3, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _AcceptedBookingCardShimmer(),
          )),
        ],
      ),
    );
  }
}

class _AcceptedBookingCardShimmer extends StatelessWidget {
  const _AcceptedBookingCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const ShimmerBox(width: 46, height: 46, radius: 12),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 100, height: 11),
              ],
            )),
            const ShimmerBox(width: 70, height: 26, radius: 13),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            const ShimmerBox(width: 16, height: 16, radius: 4),
            const SizedBox(width: 8),
            const Expanded(child: ShimmerBox(height: 13)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const ShimmerBox(width: 16, height: 16, radius: 4),
            const SizedBox(width: 8),
            const Expanded(child: ShimmerBox(height: 13)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const ShimmerBox(width: 16, height: 16, radius: 4),
            const SizedBox(width: 8),
            const Expanded(child: ShimmerBox(height: 13)),
          ]),
          const SizedBox(height: 18),
          const ShimmerBox(height: 48, radius: 14),
        ],
      ),
    );
  }
}
