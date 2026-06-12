import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/layout/common_custom_widget/mandel_network_image.dart';
import 'package:mandel_mobile_app/model/portal_ad_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/service/ads_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:shimmer/shimmer.dart';

class DealSwiperWidget extends StatefulWidget {
  const DealSwiperWidget({super.key});

  @override
  State<DealSwiperWidget> createState() => _DealSwiperWidgetState();
}

class _DealSwiperWidgetState extends State<DealSwiperWidget> {
  late final Future<List<PortalAdDto>> _future;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _future = AdsService().getAds();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PortalAdDto>>(
      future: _future,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _shimmer();
        }
        final ads = snap.data ?? [];
        if (ads.isEmpty) return _emptyCard();
        return _carousel(ads);
      },
    );
  }

  Widget _carousel(List<PortalAdDto> ads) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.88),
            itemCount: ads.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _adCard(ads[i]),
          ),
        ),
        if (ads.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(ads.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _page == i ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _page == i
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF9AA3C2).withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  void _handleTap(PortalAdDto ad) {
    final lt = ad.linkType?.toLowerCase() ?? '';
    final lv = ad.linkValue ?? '';
    if (lt == 'brand' && lv.isNotEmpty) {
      Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
          arguments: ProductSearchArguments(
              filters: {'brand': lv},
              productDetailsOptions:
                  ProductDetailsOptions(showAddToCart: true, showReturn: false)));
    } else if (lt == 'category' && lv.isNotEmpty) {
      Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
          arguments: ProductSearchArguments(
              filters: {'category': lv},
              productDetailsOptions:
                  ProductDetailsOptions(showAddToCart: true, showReturn: false)));
    } else {
      Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
          arguments: ProductSearchArguments(
              filters: {'isOnDeal': true},
              startingIndex: 1,
              productDetailsOptions:
                  ProductDetailsOptions(showAddToCart: true, showReturn: false)));
    }
  }

  Widget _adCard(PortalAdDto ad) {
    final colors = _parseGradient(ad.gradient);
    final accentColor = _parseColor(ad.accent) ?? const Color(0xFFf0560f);

    return GestureDetector(
      onTap: () => _handleTap(ad),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: colors.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Optional image overlay
            if (ad.imageUrl != null && ad.imageUrl!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox.expand(
                  child: MandelNetworkImage(
                    url: ad.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Dark scrim when image is present
            if (ad.imageUrl != null && ad.imageUrl!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            // Subtle pattern dots
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ad.tag != null && ad.tag!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: accentColor.withOpacity(0.4)),
                      ),
                      child: Text(ad.tag!,
                          style: TextStyle(
                              color: accentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(ad.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          letterSpacing: -0.3)),
                  if (ad.subtitle != null && ad.subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(ad.subtitle!,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: accentColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ad.linkType == 'brand' && (ad.linkValue ?? '').isNotEmpty
                              ? 'Shop ${ad.linkValue}'
                              : ad.cta,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C0F1E), Color(0xFF1B2860)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No promotions right now',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Check back soon for exclusive deals',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
                  arguments: ProductSearchArguments(
                      filters: {},
                      productDetailsOptions: ProductDetailsOptions(
                          showAddToCart: true, showReturn: false))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFf0560f),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Browse Products',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  List<Color> _parseGradient(String css) {
    // Parse colors from CSS gradient string like "linear-gradient(135deg,#07101e 0%,#0d2b5e 100%)"
    final hex = RegExp(r'#[0-9a-fA-F]{6}').allMatches(css).map((m) {
      final c = _parseColor(m.group(0)!);
      return c;
    }).whereType<Color>().toList();
    if (hex.length >= 2) return [hex[0], hex[1]];
    if (hex.length == 1) return [hex[0], hex[0]];
    return [const Color(0xFF0C0F1E), const Color(0xFF1B2860)];
  }

  Color? _parseColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) { return null; }
  }
}

/// Draws a subtle dot pattern over the gradient background.
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04);
    const spacing = 18.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}
