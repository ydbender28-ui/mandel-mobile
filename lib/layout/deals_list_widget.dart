import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/model/portal_deal_dto.dart';
import 'package:mandel_mobile_app/model/product_details_options.dart';
import 'package:mandel_mobile_app/model/product_search_arguments.dart';
import 'package:mandel_mobile_app/service/ads_service.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:shimmer/shimmer.dart';

class DealsListWidget extends StatefulWidget {
  const DealsListWidget({super.key});
  @override
  State<DealsListWidget> createState() => _DealsListWidgetState();
}

class _DealsListWidgetState extends State<DealsListWidget> {
  static const _primary   = Color(0xFF4F46E5);
  static const _textHi    = Color(0xFF0D1135);

  late final Future<List<PortalDealDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = AdsService().getDeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF0FA),
      appBar: AppBar(
        title: const Text('Deals & Promotions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<PortalDealDto>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _shimmer();
          }
          final deals = snap.data ?? [];
          if (deals.isEmpty) return _empty();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: deals.length,
            itemBuilder: (_, i) => _dealCard(deals[i]),
          );
        },
      ),
    );
  }

  Widget _dealCard(PortalDealDto deal) {
    final typeGradients = {
      'PRODUCT':  [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
      'BRAND':    [const Color(0xFF0EA5E9), const Color(0xFF0369A1)],
      'BULK':     [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      'CATEGORY': [const Color(0xFF10B981), const Color(0xFF059669)],
    };
    final typeIcons = {
      'PRODUCT': Icons.inventory_2_rounded,
      'BRAND':   Icons.branding_watermark_rounded,
      'BULK':    Icons.shopping_cart_rounded,
      'CATEGORY':Icons.category_rounded,
    };
    final colors = typeGradients[deal.type] ?? typeGradients['PRODUCT']!;
    final icon   = typeIcons[deal.type] ?? Icons.local_offer_rounded;

    final discStr = deal.discountType == 'PERCENT'
        ? '${deal.discountAmount.toStringAsFixed(deal.discountAmount % 1 == 0 ? 0 : 1)}% OFF'
        : '\$${deal.discountAmount.toStringAsFixed(2)} OFF';

    return GestureDetector(
      onTap: () => _navigate(deal),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: colors[0].withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deal.title,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 16,
                            fontWeight: FontWeight.w800, height: 1.2)),
                        if (deal.description != null) ...[
                          const SizedBox(height: 2),
                          Text(deal.description!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(discStr,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w900)),
                      if (deal.minQty != null)
                        Text('min qty ${deal.minQty}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + type chip
                  Row(
                    children: [
                      if (deal.badgeText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors[0].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors[0].withOpacity(0.3))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer_rounded,
                                color: colors[0], size: 12),
                              const SizedBox(width: 5),
                              Text(deal.badgeText!,
                                style: TextStyle(
                                  color: colors[0], fontSize: 11,
                                  fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _typeChip(deal.type, colors[0]),
                    ],
                  ),
                  // Items preview
                  if (deal.items.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: deal.items.take(8).map((it) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(5)),
                        child: Text(
                          it.productId != null ? '#${it.productId}' : (it.refValue ?? ''),
                          style: const TextStyle(
                            fontSize: 11, color: Color(0xFF374151),
                            fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],
                  // Date + CTA
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (deal.endDate != null) ...[
                        Icon(Icons.schedule_rounded, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('Ends ${_fmtDate(deal.endDate!)}',
                          style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500)),
                        const Spacer(),
                      ] else
                        const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Shop Deal', style: TextStyle(
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.w700)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String type, Color color) {
    const labels = {
      'PRODUCT': 'Products', 'BRAND': 'Brand',
      'BULK': 'Bulk', 'CATEGORY': 'Category',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(5)),
      child: Text(labels[type] ?? type,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
    );
  }

  void _navigate(PortalDealDto deal) {
    Map<String, dynamic> filters = {};
    if (deal.type == 'BRAND' && deal.items.isNotEmpty) {
      filters['brand'] = deal.items.first.refValue ?? '';
    } else if (deal.type == 'CATEGORY' && deal.items.isNotEmpty) {
      filters['category'] = deal.items.first.refValue ?? '';
    } else {
      filters['isOnDeal'] = true;
    }
    Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
        arguments: ProductSearchArguments(
            filters: filters,
            productDetailsOptions:
                ProductDetailsOptions(showAddToCart: true, showReturn: false)));
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/mandel_empty_state.png', width: 160, height: 160),
          const SizedBox(height: 16),
          const Text('No active deals right now',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textHi)),
          const SizedBox(height: 6),
          const Text('Check back soon for promotions',
            style: TextStyle(fontSize: 13, color: Color(0xFF9AA3C2))),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, CommonConstants.searchScreenUrl,
                arguments: ProductSearchArguments(
                    filters: {},
                    productDetailsOptions:
                        ProductDetailsOptions(showAddToCart: true, showReturn: false))),
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: const Text('Browse All Products'),
          ),
        ],
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
    '${d.month}/${d.day}/${d.year}';
}
