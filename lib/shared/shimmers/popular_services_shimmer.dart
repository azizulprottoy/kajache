import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class PopularServicesShimmer extends StatelessWidget {
  const PopularServicesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _ServiceRowShimmer(),
      ),
    );
  }
}

class AllServicesShimmer extends StatelessWidget {
  const AllServicesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => const _ServiceRowShimmer(showBadge: true),
      ),
    );
  }
}

class _ServiceRowShimmer extends StatelessWidget {
  final bool showBadge;
  const _ServiceRowShimmer({this.showBadge = false});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 14),
                const SizedBox(height: 6),
                const ShimmerBox(height: 11),
                if (showBadge) ...[
                  const SizedBox(height: 6),
                  const ShimmerBox(width: 70, height: 20, radius: 10),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const ShimmerBox(width: 60, height: 14, radius: 6),
        ],
      ),
    );
  }
}
