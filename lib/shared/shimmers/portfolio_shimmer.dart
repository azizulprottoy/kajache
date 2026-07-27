import 'package:flutter/material.dart';
import 'shimmer_helpers.dart';

class PortfolioShimmer extends StatelessWidget {
  const PortfolioShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return buildShimmer(
      context,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: _PortfolioCardShimmer(),
        ),
      ),
    );
  }
}

class _PortfolioCardShimmer extends StatelessWidget {
  const _PortfolioCardShimmer();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 180, height: 16, radius: 5),
                SizedBox(height: 8),
                ShimmerBox(height: 13),
                SizedBox(height: 5),
                ShimmerBox(height: 13),
                SizedBox(height: 5),
                ShimmerBox(width: 200, height: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
