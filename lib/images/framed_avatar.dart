import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:simply_widgets/images/cachedImage.dart';

class FramedAvatar extends StatelessWidget {
  const FramedAvatar({super.key, required this.size, required this.radius, required this.url, required this.cacheManager});

  final double size;
  final double radius;
  final String url;
  final CacheManager cacheManager;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedImage(
          url: url,
          cacheKey: url,
          width: size,
          height: size,
          cacheManager: cacheManager,
        ));
  }
}
