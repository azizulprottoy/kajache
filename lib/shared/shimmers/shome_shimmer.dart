import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class ShomeShimmer extends StatelessWidget {
  const ShomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome hero card
            const ShimmerBox(height: 90, radius: 20),
            const SizedBox(height: 20),
            // "Today Overview" heading
            const ShimmerBox(width: 140, height: 18, radius: 6),
            const SizedBox(height: 12),
            // 2 stat cards row 1
            Row(children: [
              Expanded(child: ShimmerBox(height: 110, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 110, radius: 18)),
            ]),
            const SizedBox(height: 12),
            // 2 stat cards row 2
            Row(children: [
              Expanded(child: ShimmerBox(height: 110, radius: 18)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 110, radius: 18)),
            ]),
            const SizedBox(height: 24),
            // "Available Jobs" heading
            const ShimmerBox(width: 120, height: 18, radius: 6),
            const SizedBox(height: 12),
            // 3 job tiles
            ...List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _JobTileShimmer(),
            )),
            const SizedBox(height: 24),
            // "Recent Activities" heading
            const ShimmerBox(width: 150, height: 18, radius: 6),
            const SizedBox(height: 12),
            // 3 activity tiles
            ...List.generate(3, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _ActivityTileShimmer(),
            )),
          ],
        ),
      ),
    );
  }
}

class _JobTileShimmer extends StatelessWidget {
  const _JobTileShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(children: [
            const ShimmerBox(width: 46, height: 46, radius: 12),
            const SizedBox(width: 12),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14),
                SizedBox(height: 6),
                ShimmerBox(height: 11, width: 120),
              ],
            )),
            const ShimmerBox(width: 55, height: 16, radius: 6),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const ShimmerBox(width: 14, height: 14, radius: 3),
            const SizedBox(width: 6),
            const ShimmerBox(width: 80, height: 11, radius: 4),
            const SizedBox(width: 12),
            const ShimmerBox(width: 14, height: 14, radius: 3),
            const SizedBox(width: 6),
            const ShimmerBox(width: 60, height: 11, radius: 4),
            const Spacer(),
            const ShimmerBox(width: 70, height: 24, radius: 12),
          ]),
        ],
      ),
    );
  }
}

class _ActivityTileShimmer extends StatelessWidget {
  const _ActivityTileShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
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
            ShimmerBox(height: 11, width: 160),
          ],
        )),
      ]),
    );
  }
}
