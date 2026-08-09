import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/advertisement_controller.dart';
import '../model/advertisement_model.dart';

class AdBanner extends StatelessWidget {
  final String position;
  final EdgeInsetsGeometry padding;

  const AdBanner({
    super.key,
    required this.position,
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
            ? _AdImage(ad: ads.first, onTap: () => ctrl.trackClick(ads.first.id))
            : _AdCarousel(ads: ads, onTap: ctrl.trackClick),
      );
    });
  }
}

// ── Auto-advancing PageView carousel ─────────────────────────────────────────
class _AdCarousel extends StatefulWidget {
  final List<AdvertisementModel> ads;
  final void Function(String adId) onTap;

  const _AdCarousel({required this.ads, required this.onTap});

  @override
  State<_AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<_AdCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;
  double? _ratio;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
    _readRatio();
  }

  void _readRatio() {
    if (widget.ads.isEmpty) return;
    NetworkImage(widget.ads.first.imageUrl)
        .resolve(ImageConfiguration.empty)
        .addListener(ImageStreamListener((info, _) {
      if (mounted) {
        setState(() => _ratio = info.image.width / info.image.height);
      }
    }));
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
    return AspectRatio(
      aspectRatio: _ratio ?? 2.5,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: widget.ads.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.ads[i].imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Single ad image — reads actual image ratio ───────────────────────────────
class _AdImage extends StatefulWidget {
  final AdvertisementModel ad;
  final VoidCallback onTap;

  const _AdImage({required this.ad, required this.onTap});

  @override
  State<_AdImage> createState() => _AdImageState();
}

class _AdImageState extends State<_AdImage> {
  double? _ratio;

  @override
  void initState() {
    super.initState();
    _readRatio();
  }

  void _readRatio() {
    final stream = NetworkImage(widget.ad.imageUrl)
        .resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((info, _) {
      if (mounted) {
        setState(() {
          _ratio = info.image.width / info.image.height;
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_ratio == null) {
      return AspectRatio(
        aspectRatio: 2.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(color: colorScheme.surfaceContainerLowest),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: _ratio!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.ad.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
