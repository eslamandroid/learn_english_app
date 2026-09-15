import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';
import 'package:learn_english_app/resources/app_resources.dart';

const imageKey = "learn_english_app";

/// Single shared cache manager. Building a `CacheManager` is expensive and must
/// not happen per-build/per-widget — one instance is reused process-wide so the
/// in-memory + disk caches are actually shared.
final CacheManager appImageCacheManager = CacheManager(
  Config(
    imageKey,
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 300,
  ),
);

class ImageViewFromUrl extends StatefulWidget {
  final String url;
  final BoxFit? fit;
  final double? height;
  final double width;
  final double radius;
  final Color? borderColor;
  final Widget? error;
  final Widget? placeholder;
  final double errorPadding;
  final BorderRadius? borderRadius;
  final Alignment? alignment;
  final String? cacheKey;

  /// Explicit decode width override (logical px). When null it's derived from
  /// [width] × devicePixelRatio so bitmaps are decoded at display size instead
  /// of full resolution.
  final int? memCacheWidth;

  /// Keep the element alive while scrolled out of a lazy list. Defaults to
  /// false so off-screen images are released — keeping them all alive defeats
  /// viewport recycling and bloats memory.
  final bool keepAlive;

  const ImageViewFromUrl({
    super.key,
    required this.url,
    required this.width,
    this.height,
    this.radius = 0.0,
    this.errorPadding = 10.0,
    this.fit,
    this.borderColor,
    this.error,
    this.placeholder,
    this.borderRadius,
    this.alignment,
    this.cacheKey,
    this.memCacheWidth,
    this.keepAlive = false,
  });

  @override
  State<ImageViewFromUrl> createState() => _ImageViewFromUrlState();
}

class _ImageViewFromUrlState extends State<ImageViewFromUrl>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final borderRadius = widget.borderRadius ??
        BorderRadius.only(
          topLeft: Radius.circular(widget.radius),
          topRight: Radius.circular(widget.radius),
        );

    // Decode to display size: this is the biggest memory win for image lists.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memWidth = widget.memCacheWidth ??
        (widget.width.isFinite ? (widget.width * dpr).round() : null);
    final h = widget.height;
    final memHeight = (memWidth == null && h != null && h.isFinite)
        ? (h * dpr).round()
        : null;

    Widget image = CachedNetworkImage(
      imageUrl: widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.cover,
      alignment: widget.alignment ?? Alignment.center,
      fadeInDuration: const Duration(milliseconds: 150),
      fadeOutDuration: const Duration(milliseconds: 100),
      filterQuality: FilterQuality.medium,
      cacheKey: widget.cacheKey,
      cacheManager: appImageCacheManager,
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      placeholder: (context, url) =>
          widget.placeholder ??
          Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: SpinKitPulse(color: context.colorScheme.primary),
            ),
          ),
      errorWidget: (context, url, error) => Padding(
        padding: EdgeInsets.all(widget.errorPadding),
        child: widget.error ?? Image.asset(AppImages.appLogoColored),
      ),
    );

    // Only paint a border layer when one is actually requested.
    if (widget.borderColor != null) {
      image = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: widget.borderColor!),
        ),
        child: image,
      );
    }

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: Clip.hardEdge,
        child: image,
      ),
    );
  }
}

ImageProvider imageProvider(String url) {
  return CachedNetworkImageProvider(url, cacheManager: appImageCacheManager);
}
