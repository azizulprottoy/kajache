import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for `Image.network` backed by the disk cache of
/// `cached_network_image`, decoded at display size instead of full size.
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  /// Decode width in physical pixels. Defaults to [width] (or the screen
  /// width when [width] is unbounded) times the device pixel ratio.
  final int? memCacheWidth;

  /// Shown while loading. Defaults to an empty box.
  final Widget? placeholder;

  /// Same shape as `Image.network`'s `errorBuilder`.
  final ImageErrorWidgetBuilder? errorBuilder;

  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.memCacheWidth,
    this.placeholder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final logicalWidth = (width != null && width!.isFinite)
        ? width!
        : media.size.width;

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth:
          memCacheWidth ?? (logicalWidth * media.devicePixelRatio).round(),
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => placeholder ?? SizedBox(width: width, height: height),
      errorWidget: (context, _, error) =>
          errorBuilder?.call(context, error, null) ??
          SizedBox(width: width, height: height),
    );
  }
}

/// Cached, downscaled image provider for avatars and decoration images.
/// [width] is the decode width in physical pixels.
ImageProvider appNetworkImageProvider(String url, {int width = 256}) {
  return ResizeImage(
    CachedNetworkImageProvider(url),
    width: width,
    allowUpscaling: false,
  );
}
