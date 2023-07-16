import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:simply_widgets/images/cachedImage.dart';
import 'package:styled_widget/styled_widget.dart';

class FramedAvatar extends StatelessWidget {
  const FramedAvatar(
      {super.key, required this.size, required this.radius, this.frameColor = Colors.transparent, required this.url, required this.cacheManager});

  final double size;
  final double radius;
  final String url;
  final Color frameColor;
  final CacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), color: frameColor),
            child: CachedImage(
              url: url,
              cacheKey: url,
              width: size,
              height: size,
              noneColor: Colors.black,
              cacheManager: cacheManager,
            ).padding(all: 3)));
  }
}
