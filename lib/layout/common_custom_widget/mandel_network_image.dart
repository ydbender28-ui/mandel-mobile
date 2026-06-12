import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

/// Loads images via Dio with the session auth token, bypassing browser CORS/cache issues.
/// Pass [width]/[height] = null to have the image fill its parent (BoxFit.cover).
class MandelNetworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const MandelNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MandelNetworkImage> createState() => _MandelNetworkImageState();
}

class _MandelNetworkImageState extends State<MandelNetworkImage>
    with AuthSupportUtility {
  static final _cache = <String, Uint8List?>{};
  static const _maxCacheSize = 200;
  static final _sentinel = Uint8List(0);

  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MandelNetworkImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      setState(() { _loading = true; _bytes = null; });
      _load();
    }
  }

  void _load() {
    if (_cache.containsKey(widget.url)) {
      if (mounted) setState(() { _bytes = _cache[widget.url]; _loading = false; });
      return;
    }
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final token = await getTokenFromSession();
      final dio = Dio();
      final resp = await dio.get<List<int>>(
        widget.url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            CommonConstants.authorization: '${CommonConstants.bearer}$token',
          },
          validateStatus: (s) => s != null && s < 400,
        ),
      );
      if (resp.data == null || resp.data!.isEmpty) {
        _storeAndSet(widget.url, _sentinel);
        return;
      }
      _storeAndSet(widget.url, Uint8List.fromList(resp.data!));
    } catch (_) {
      _storeAndSet(widget.url, _sentinel);
    }
  }

  void _storeAndSet(String url, Uint8List bytes) {
    if (_cache.length >= _maxCacheSize) _cache.remove(_cache.keys.first);
    _cache[url] = bytes;
    if (mounted) setState(() { _bytes = bytes; _loading = false; });
  }

  Widget _sized(Widget child) {
    if (widget.width == null && widget.height == null) {
      return SizedBox.expand(child: child);
    }
    return SizedBox(width: widget.width, height: widget.height, child: child);
  }

  Widget _placeholder() => _sized(Image.asset(
    'assets/images/mandel_no_image.jpg',
    fit: widget.fit));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _sized(const Center(child: SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 1.5,
          color: Color(0xFF9AA3C2)))));
    }
    final b = _bytes;
    if (b == null || b.isEmpty) return _placeholder();
    return _sized(Image.memory(b,
      fit: widget.fit,
      errorBuilder: (_, __, ___) => _placeholder()));
  }
}
