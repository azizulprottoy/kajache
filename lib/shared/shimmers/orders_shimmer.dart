import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class OrdersShimmer extends StatelessWidget {
  const OrdersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: _OrderCardShimmer(),
        ),
      ),
    );
  }
}

class _OrderCardShimmer extends StatelessWidget {
  const _OrderCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(children: [
            const ShimmerBox(width: 54, height: 54, radius: 14),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 100, height: 11, radius: 4),
              ],
            )),
            const ShimmerBox(width: 55, height: 14, radius: 6),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const ShimmerBox(width: 14, height: 14, radius: 3),
            const SizedBox(width: 6),
            const ShimmerBox(width: 90, height: 11, radius: 4),
            const Spacer(),
            const ShimmerBox(width: 70, height: 24, radius: 12),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const ShimmerBox(width: 14, height: 14, radius: 3),
            const SizedBox(width: 6),
            const ShimmerBox(width: 50, height: 11, radius: 4),
            const Spacer(),
            const ShimmerBox(width: 80, height: 24, radius: 8),
          ]),
        ],
      ),
    );
  }
}
