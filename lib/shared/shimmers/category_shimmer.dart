import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: GridView.builder(
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
    );
  }
}
