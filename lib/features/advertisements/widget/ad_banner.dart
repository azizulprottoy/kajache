import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/advertisement_controller.dart';
import '../model/advertisement_model.dart';

class AdBanner extends StatelessWidget {
  final String position;
  final double height;
  final EdgeInsetsGeometry padding;

  const AdBanner({
    super.key,
    required this.position,
    this.height = 120,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdvertisementController>()) return const SizedBox.shrink();

    return Obx(() {
      final ctrl = AdvertisementController.to;
      final ads = ctrl.adsFor(position);
      if (ads.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: padding,
        child: ads.length == 1
            ? _AdImage(ad: ads.first, height: height, onTap: () => ctrl.trackClick(ads.first.id))
            : _AdCarousel(ads: ads, height: height, onTap: ctrl.trackClick),
      );
    });
  }
}

// ── Auto-advancing PageView carousel ────────────────────────────────────────
class _AdCarousel extends StatefulWidget {
  final List<AdvertisementModel> ads;
  final double height;
  final void Function(String adId) onTap;

  const _AdCarousel({required this.ads, required this.height, required this.onTap});

  @override
  State<_AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<_AdCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _current = (_current + 1) % widget.ads.length;
      _pageController.animateToPage(
        _current,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: widget.ads.length,
        itemBuilder: (_, i) => _AdImage(
          ad: widget.ads[i],
          height: widget.height,
          onTap: () => widget.onTap(widget.ads[i].id),
        ),
      ),
    );
  }
}

// ── Single ad image ──────────────────────────────────────────────────────────
class _AdImage extends StatelessWidget {
  final AdvertisementModel ad;
  final double height;
  final VoidCallback onTap;

  const _AdImage({required this.ad, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          ad.imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
