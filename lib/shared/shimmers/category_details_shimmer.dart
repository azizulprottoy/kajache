import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class CategoryDetailsShimmer extends StatelessWidget {
  const CategoryDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const ShimmerBox(height: 190, radius: 16),
          const SizedBox(height: 20),
          const ShimmerBox(height: 26, radius: 6),
          const SizedBox(height: 8),
          const ShimmerBox(width: 140, height: 14, radius: 4),
          const SizedBox(height: 16),
          const ShimmerBox(height: 14),
          const SizedBox(height: 6),
          const ShimmerBox(height: 14),
          const SizedBox(height: 6),
          const ShimmerBox(width: 200, height: 14),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const ShimmerBox(width: 100, height: 18, radius: 6),
          const SizedBox(height: 12),
          ...List.generate(4, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _ServiceCardShimmer(),
          )),
        ],
      ),
    );
  }
}

/// Standalone shimmer for the services list section (used when only services are reloading).
class CategoryServicesShimmer extends StatelessWidget {
  const CategoryServicesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: Column(
        children: List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _ServiceCardShimmer(),
          ),
        ),
      ),
    );
  }
}

class _ServiceCardShimmer extends StatelessWidget {
  const _ServiceCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 72, height: 72, radius: 10),
          const SizedBox(width: 12),
          const Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 14),
              SizedBox(height: 6),
              ShimmerBox(height: 11),
              SizedBox(height: 6),
              ShimmerBox(height: 11, width: 180),
            ],
          )),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const ShimmerBox(width: 70, height: 14, radius: 6),
              const SizedBox(height: 8),
              const ShimmerBox(width: 80, height: 36, radius: 12),
            ],
          ),
        ],
      ),
    );
  }
}
