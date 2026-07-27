import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class ServiceDetailsShimmer extends StatelessWidget {
  const ServiceDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Hero image
          const ShimmerBox(height: 190, radius: 16),
          const SizedBox(height: 20),
          // Title
          const ShimmerBox(height: 26, radius: 6),
          const SizedBox(height: 8),
          // Slug
          const ShimmerBox(width: 140, height: 14, radius: 4),
          const SizedBox(height: 16),
          // Customer budget card
          const ShimmerBox(height: 48, radius: 14),
          const SizedBox(height: 12),
          // Poster card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 80, height: 12, radius: 4),
                const SizedBox(height: 12),
                Row(children: [
                  const ShimmerCircle(size: 54),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 16),
                      SizedBox(height: 6),
                      ShimmerBox(height: 12, width: 120),
                    ],
                  )),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: ShimmerBox(height: 48, radius: 10)),
                  const SizedBox(width: 10),
                  Expanded(child: ShimmerBox(height: 48, radius: 10)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Description (4 lines)
          const ShimmerBox(height: 14),
          const SizedBox(height: 6),
          const ShimmerBox(height: 14),
          const SizedBox(height: 6),
          const ShimmerBox(height: 14),
          const SizedBox(height: 6),
          const ShimmerBox(width: 220, height: 14),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Rating card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  const ShimmerBox(width: 60, height: 50, radius: 8),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 80, height: 14, radius: 4),
                  const SizedBox(height: 4),
                  const ShimmerBox(width: 60, height: 11, radius: 4),
                ]),
                const SizedBox(width: 20),
                Expanded(child: Column(
                  children: List.generate(5, (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      const ShimmerBox(width: 20, height: 11, radius: 4),
                      const SizedBox(width: 8),
                      Expanded(child: ShimmerBox(height: 8, radius: 99)),
                      const SizedBox(width: 8),
                      const ShimmerBox(width: 20, height: 11, radius: 4),
                    ]),
                  )),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Comment input placeholder
          const ShimmerBox(height: 52, radius: 14),
          const SizedBox(height: 16),
          // 2 comment cards
          ...List.generate(2, (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _CommentCardShimmer(),
          )),
        ],
      ),
    );
  }
}

class _CommentCardShimmer extends StatelessWidget {
  const _CommentCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const ShimmerCircle(size: 32),
            const SizedBox(width: 8),
            const Expanded(child: ShimmerBox(height: 13)),
            const SizedBox(width: 12),
            const ShimmerBox(width: 60, height: 11, radius: 4),
          ]),
          const SizedBox(height: 8),
          const ShimmerBox(height: 13),
          const SizedBox(height: 5),
          const ShimmerBox(width: 200, height: 13),
        ],
      ),
    );
  }
}
