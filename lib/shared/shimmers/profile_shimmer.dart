import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const ShimmerCircle(size: 84),
                  const SizedBox(height: 12),
                  const ShimmerBox(width: 160, height: 22, radius: 6),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 100, height: 16, radius: 4),
                  const SizedBox(height: 16),
                  const ShimmerBox(height: 48, radius: 14),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Basic info section
            _ProfileSectionShimmer(rowCount: 4),
            const SizedBox(height: 16),
            // Details section
            _ProfileSectionShimmer(rowCount: 5),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionShimmer extends StatelessWidget {
  final int rowCount;
  const _ProfileSectionShimmer({required this.rowCount});

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
          const ShimmerBox(width: 140, height: 16, radius: 5),
          const SizedBox(height: 14),
          ...List.generate(rowCount, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              const ShimmerBox(width: 110, height: 13, radius: 4),
              const SizedBox(width: 12),
              const Expanded(child: ShimmerBox(height: 13)),
            ]),
          )),
        ],
      ),
    );
  }
}
