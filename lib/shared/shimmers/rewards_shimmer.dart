import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class RewardsShimmer extends StatelessWidget {
  const RewardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          // Hero points card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 14, radius: 4),
                SizedBox(height: 10),
                ShimmerBox(width: 100, height: 48, radius: 8),
                SizedBox(height: 14),
                ShimmerBox(height: 8, radius: 99),
                SizedBox(height: 8),
                ShimmerBox(width: 200, height: 12, radius: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 150, height: 18, radius: 6),
          const SizedBox(height: 16),
          // 4 timeline checklist items
          ...List.generate(4, (_) => const _ChecklistItemShimmer()),
        ],
      ),
    );
  }
}

class _ChecklistItemShimmer extends StatelessWidget {
  const _ChecklistItemShimmer();
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Expanded(flex: 1, child: Center(
                  child: Container(width: 2, color: Colors.white),
                )),
                const ShimmerCircle(size: 28),
                Expanded(flex: 3, child: Center(
                  child: Container(width: 2, color: Colors.white),
                )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(children: [
                  const ShimmerBox(width: 46, height: 46, radius: 12),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14),
                      SizedBox(height: 6),
                      ShimmerBox(height: 11, width: 180),
                      SizedBox(height: 8),
                      ShimmerBox(width: 90, height: 16, radius: 8),
                    ],
                  )),
                  const SizedBox(width: 8),
                  const ShimmerBox(width: 36, height: 26, radius: 13),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
