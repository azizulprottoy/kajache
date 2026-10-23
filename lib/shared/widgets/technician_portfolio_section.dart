import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/html_text.dart';
import '../../core/utils/translation_keys.dart';
import '../../features/portfolio/model/portfolio_model.dart';
import '../../features/portfolio/repository/portfolio_repository.dart';
import '../shimmers/shimmer_helpers.dart';
import 'app_network_image.dart';

/// A technician's portfolio for profile sheets: heading with count, a
/// horizontal strip of thumbnails, tap to open a full-screen viewer.
///
/// [technicianId] is the technician's User `_id` (what portfolio items
/// store as `technitianId`), not the technician profile id.
class TechnicianPortfolioSection extends StatefulWidget {
  final String technicianId;
  final double thumbnailSize;

  const TechnicianPortfolioSection({
    super.key,
    required this.technicianId,
    this.thumbnailSize = 96,
  });

  @override
  State<TechnicianPortfolioSection> createState() =>
      _TechnicianPortfolioSectionState();
}

class _TechnicianPortfolioSectionState extends State<TechnicianPortfolioSection> {
  final _repository = PortfolioRepository();

  List<PortfolioItem> _items = const [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant TechnicianPortfolioSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.technicianId != widget.technicianId) _load();
  }

  Future<void> _load() async {
    if (widget.technicianId.isEmpty) {
      setState(() {
        _items = const [];
        _loading = false;
        _failed = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      final items = await _repository.getPortfolios(
        technitianId: widget.technicianId,
      );
      if (!mounted) return;
      setState(() {
        _items = items.where((item) => item.image.isNotEmpty).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined, size: 20, color: colors.primary),
            const SizedBox(width: 8),
            Text(
              TKeys.portfolio.tr,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            if (!_loading && !_failed && _items.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_items.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        _buildBody(context),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = widget.thumbnailSize;

    if (_loading) {
      return SizedBox(
        height: size,
        child: buildShimmer(
          context,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => ShimmerBox(width: size, height: size, radius: 14),
          ),
        ),
      );
    }

    if (_failed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 18, color: colors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                TKeys.portfolioLoadFailed.tr,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(TKeys.retry.tr),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.image_not_supported_outlined, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                TKeys.noPortfolioYet.tr,
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: size,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Material(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openViewer(context, index),
              child: Hero(
                tag: 'portfolio-${item.id}-$index',
                child: AppNetworkImage(
                  item.imageUrl,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => SizedBox(
                    width: size,
                    height: size,
                    child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => PortfolioImageViewer(
          items: _items,
          initialIndex: index,
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

/// Full-screen swipeable viewer with pinch zoom and the service details as
/// the caption.
class PortfolioImageViewer extends StatefulWidget {
  final List<PortfolioItem> items;
  final int initialIndex;

  const PortfolioImageViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  State<PortfolioImageViewer> createState() => _PortfolioImageViewerState();
}

class _PortfolioImageViewerState extends State<PortfolioImageViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caption = htmlToPlainText(widget.items[_index].servicedetails);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: Hero(
                    tag: 'portfolio-${item.id}-$i',
                    child: AppNetworkImage(
                      item.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: TKeys.close.tr,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                  ),
                  const Spacer(),
                  if (widget.items.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_index + 1} / ${widget.items.length}',
                        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (caption.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          caption,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
