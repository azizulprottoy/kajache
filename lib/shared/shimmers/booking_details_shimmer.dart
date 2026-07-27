import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class BookingDetailsShimmer extends StatelessWidget {
  const BookingDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Service card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const ShimmerBox(width: 76, height: 76, radius: 12),
              const SizedBox(width: 12),
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 16),
                  SizedBox(height: 6),
                  ShimmerBox(width: 120, height: 13),
                  SizedBox(height: 6),
                  ShimmerBox(width: 90, height: 11),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 16),
          // Booking info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 13),
                const SizedBox(height: 6),
                const ShimmerBox(height: 13, width: 240),
                const Divider(height: 28, color: Colors.white),
                Row(children: [
                  const ShimmerBox(width: 18, height: 18, radius: 4),
                  const SizedBox(width: 8),
                  const Expanded(child: ShimmerBox(height: 13)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  const ShimmerBox(width: 18, height: 18, radius: 4),
                  const SizedBox(width: 8),
                  const Expanded(child: ShimmerBox(height: 13)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Client card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 70, height: 12, radius: 4),
                const SizedBox(height: 12),
                Row(children: [
                  const ShimmerCircle(size: 56),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 16),
                      SizedBox(height: 6),
                      ShimmerBox(width: 120, height: 12),
                    ],
                  )),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: ShimmerBox(height: 52, radius: 10)),
                  const SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 52, radius: 10)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Bids section heading
          Row(children: [
            const ShimmerBox(width: 120, height: 18, radius: 6),
            const SizedBox(width: 8),
            const ShimmerBox(width: 28, height: 24, radius: 12),
          ]),
          const SizedBox(height: 10),
          // 3 bid cards
          ...List.generate(3, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _BidCardShimmer(),
          )),
        ],
      ),
    );
  }
}

class _BidCardShimmer extends StatelessWidget {
  const _BidCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(children: [
            const ShimmerCircle(size: 42),
            const SizedBox(width: 10),
            const Expanded(child: ShimmerBox(height: 14)),
            const SizedBox(width: 8),
            const ShimmerBox(width: 60, height: 14, radius: 6),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const ShimmerBox(width: 16, height: 16, radius: 4),
            const SizedBox(width: 8),
            const Expanded(child: ShimmerBox(height: 12)),
          ]),
        ],
      ),
    );
  }
}
