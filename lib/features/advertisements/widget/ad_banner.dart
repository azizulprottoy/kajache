import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/advertisement_controller.dart';
import '../model/advertisement_model.dart';
import 'package:kaj_ache/shared/widgets/app_network_image.dart';

class AdBanner extends StatelessWidget {
  final String position;
  final EdgeInsetsGeometry padding;

  const AdBanner({
    super.key,
    required this.position,
    this.padding = const EdgeInsets.only(bottom: 5),
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

/// Reads an ad image's aspect ratio, removing the stream listener when the
/// URL changes or the widget is disposed.
mixin _ImageRatioReader<T extends StatefulWidget> on State<T> {
  double? ratio;
  ImageStream? _ratioStream;
  ImageStreamListener? _ratioListener;

  void readRatio(String? url) {
    _stopReadingRatio();
    if (url == null || url.isEmpty) return;
    // A tiny decode is enough to know the ratio; the bytes come from the
    // same disk cache the displayed image uses.
    final stream = appNetworkImageProvider(url, width: 64)
        .resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        final w = info.image.width, h = info.image.height;
        info.dispose();
        if (mounted && h > 0) setState(() => ratio = w / h);
      },
      onError: (_, __) {},
    );
    stream.addListener(listener);
    _ratioStream = stream;
    _ratioListener = listener;
  }

  void _stopReadingRatio() {
    final listener = _ratioListener;
    if (listener != null) _ratioStream?.removeListener(listener);
    _ratioStream = null;
    _ratioListener = null;
  }

  @override
  void dispose() {
    _stopReadingRatio();
    super.dispose();
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

class _AdCarouselState extends State<_AdCarousel>
    with _ImageRatioReader<_AdCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  String? get _firstUrl =>
      widget.ads.isEmpty ? null : widget.ads.first.imageUrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
    readRatio(_firstUrl);
  }

  @override
  void didUpdateWidget(covariant _AdCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl =
        oldWidget.ads.isEmpty ? null : oldWidget.ads.first.imageUrl;
    if (oldUrl != _firstUrl) readRatio(_firstUrl);
    if (_current >= widget.ads.length) _current = 0;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.ads.isEmpty || !_pageController.hasClients) return;
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
      aspectRatio: ratio ?? 2.5,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: widget.ads.length,
        itemBuilder: (_, i) => ClipRRect(
          // borderRadius: BorderRadius.circular(14),
          child: AppNetworkImage(
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

class _AdImageState extends State<_AdImage> with _ImageRatioReader<_AdImage> {
  @override
  void initState() {
    super.initState();
    readRatio(widget.ad.imageUrl);
  }

  @override
  void didUpdateWidget(covariant _AdImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ad.imageUrl != widget.ad.imageUrl) {
      ratio = null;
      readRatio(widget.ad.imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final ratio = this.ratio;
    if (ratio == null) {
      return AspectRatio(
        aspectRatio: 2.5,
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(14),
          child: Container(color: colorScheme.surfaceContainerLowest),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: ratio,
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(14),
          child: AppNetworkImage(
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
