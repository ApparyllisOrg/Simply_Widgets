import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedImage extends StatefulWidget {
  const CachedImage(
      {super.key,
      required this.url,
      required this.cacheKey,
      required this.width,
      required this.height,
      this.noneColor = Colors.grey,
      this.missingSize,
      this.missingIcon = Icons.person,
      this.onLoaded,
      this.loadingText = 'Loading avatar',
      required this.cacheManager,
      this.loader = const CircularProgressIndicator()});
  final String url;
  final String cacheKey;
  final double width;
  final double height;
  final Color noneColor;
  final IconData missingIcon;
  final Function? onLoaded;
  final double? missingSize;
  final String loadingText;
  final CacheManager cacheManager;
  final Widget loader;

  @override
  State<StatefulWidget> createState() => _CachedImage();
}

class _CachedImage extends State<CachedImage> {
  bool loading = true;
  String lastUrl = '';
  Widget? widgetOverride;
  int getVersion = 0;
  File? _cachedFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getImage();
  }

  Future<void> getImage() async {
    if (kIsWeb) {
      widgetOverride = Image.network(
        lastUrl,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, obj, stack) => Icon(
          widget.missingIcon,
          color: widget.noneColor,
          size: widget.missingSize ?? widget.width,
        ),
      );
      setState(() {});
    } else {
      if (widget.url.isNotEmpty == true) {
        getVersion++;

        _cachedFile = null;

        int previousVersion = getVersion;

        FileInfo? cachedFile = await widget.cacheManager.getFileFromCache(widget.url).catchError((err) {
          print(err);
          return null;
        });
        ;
        if (cachedFile != null) {
          if (previousVersion == getVersion) {
            _cachedFile = cachedFile.file;
          }
        } else {
          try {
            FileInfo fileInfo = await widget.cacheManager.downloadFile(widget.url);
            if (previousVersion == getVersion) {
              _cachedFile = fileInfo.file;
            }
          } catch (e) {}
        }

        loading = false;

        if (mounted) {
          setState(() {});
        }
      } else {
        if (mounted) {
          _cachedFile = null;
          loading = false;
          setState(() {});
        }
      }
    }
  }

  Widget getMissingIcon() => Center(
          child: Icon(
        widget.missingIcon,
        color: widget.noneColor,
        semanticLabel: '',
        size: widget.missingSize ?? widget.width,
      ));

  @override
  Widget build(BuildContext context) {
    if (widget.url != lastUrl) {
      lastUrl = widget.url;
      loading = true;
      getImage();
    }

    if (widgetOverride != null) {
      return SizedBox(width: widget.width, height: widget.height, child: ClipRRect(borderRadius: BorderRadius.circular(5), child: widgetOverride));
    }

    if (loading) {
      return Semantics(
        child: SizedBox(width: widget.width, height: widget.height, child: widget.loader),
        label: widget.loadingText,
      );
    }

    if (widget.onLoaded != null) widget.onLoaded!(_cachedFile != null);

    return _cachedFile == null
        ? SizedBox(width: widget.width, height: widget.height, child: getMissingIcon())
        : ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              _cachedFile!,
              semanticLabel: '',
              width: widget.width,
              height: widget.height,
            ));
  }
}
