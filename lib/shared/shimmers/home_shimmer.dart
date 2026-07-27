import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Banner placeholder
            const ShimmerBox(height: 190, radius: 16),
            const SizedBox(height: 16),
            // Section header row
            const _SectionHeaderShimmer(),
            const SizedBox(height: 12),
            // Category grid (8 tiles, 4 cols)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: 8,
              itemBuilder: (_, __) => Column(
                children: [
                  Expanded(child: ShimmerBox(radius: 12)),
                  const SizedBox(height: 6),
                  ShimmerBox(height: 10, width: 48, radius: 4),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeaderShimmer(),
            const SizedBox(height: 12),
            // 4 service rows
            ...List.generate(4, (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _ServiceRowShimmer(),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeaderShimmer extends StatelessWidget {
  const _SectionHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        ShimmerBox(width: 130, height: 18, radius: 6),
        Spacer(),
        ShimmerBox(width: 55, height: 14, radius: 6),
      ],
    );
  }
}

class _ServiceRowShimmer extends StatelessWidget {
  const _ServiceRowShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 72, height: 72, radius: 10),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14),
                SizedBox(height: 6),
                ShimmerBox(height: 11),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 60, height: 14, radius: 6),
        ],
      ),
    );
  }
}
