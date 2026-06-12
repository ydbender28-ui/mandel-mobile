import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

/// Loads images via Dio with the session auth token, bypassing browser CORS/cache issues.
class MandelNetworkImage extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const MandelNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  State<MandelNetworkImage> createState() => _MandelNetworkImageState();
}

class _MandelNetworkImageState extends State<MandelNetworkImage>
    with AuthSupportUtility {
  // Simple in-memory cache shared across all instances.
  static final _cache = <String, Uint8List?>{};
  static const _maxCacheSize = 200;

  // null = loading, _sentinel = error, otherwise bytes
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
      final bytes = Uint8List.fromList(resp.data!);
      _storeAndSet(widget.url, bytes);
    } catch (_) {
      _storeAndSet(widget.url, _sentinel);
    }
  }

  void _storeAndSet(String url, Uint8List bytes) {
    if (_cache.length >= _maxCacheSize) _cache.remove(_cache.keys.first);
    _cache[url] = bytes;
    if (mounted) setState(() { _bytes = bytes; _loading = false; });
  }

  Widget _placeholder() => Image.asset(
    'assets/images/mandel_no_image.jpg',
    width: widget.width, height: widget.height, fit: widget.fit);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.width, height: widget.height,
        child: const Center(child: SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(strokeWidth: 1.5,
            color: Color(0xFF9AA3C2)))));
    }
    final b = _bytes;
    if (b == null || b.isEmpty) return _placeholder();
    return Image.memory(b,
      width: widget.width, height: widget.height, fit: widget.fit,
      errorBuilder: (_, __, ___) => _placeholder());
  }
}
