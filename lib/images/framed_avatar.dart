import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:simply_widgets/images/cachedImage.dart';
import 'package:styled_widget/styled_widget.dart';

class FramedAvatar extends StatelessWidget {
  const FramedAvatar(
      {super.key,
      required this.size,
      required this.radius,
      this.frameColor = Colors.transparent,
      required this.url,
      required this.cacheManager,
      this.painter,
      this.imagePadding = 3,
      this.clipper,
      this.missingIcon = Icons.people});

  final double size;
  final double radius;
  final double imagePadding;
  final String url;
  final Color frameColor;
  final CustomPainter? painter;
  final CustomClipper<Path>? clipper;
  final CacheManager cacheManager;
  final IconData missingIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), color: frameColor),
        child: CustomPaint(
            painter: painter,
            child: ClipPath(
                clipper: clipper,
                child: CachedImage(
                  url: url,
                  cacheKey: url,
                  width: size,
                  height: size,
                  missingIcon: missingIcon,
                  noneColor: Colors.grey,
                  cacheManager: cacheManager,
                ).clipRRect(all: radius).padding(all: imagePadding))));
  }
}
