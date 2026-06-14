class PortalSaleItemDto {
  final int id;
  final int productId;
  final double salePrice;

  const PortalSaleItemDto({required this.id, required this.productId, required this.salePrice});

  factory PortalSaleItemDto.fromJson(Map<String, dynamic> j) => PortalSaleItemDto(
    id:        (j['id'] as num?)?.toInt() ?? 0,
    productId: (j['productId'] as num?)?.toInt() ?? 0,
    salePrice: ((j['salePrice'] ?? 0) as num).toDouble(),
  );
}

class PortalSaleDto {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? bannerGradient;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<PortalSaleItemDto> items;

  const PortalSaleDto({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.bannerGradient,
    this.startDate,
    this.endDate,
    this.items = const [],
  });

  factory PortalSaleDto.fromJson(Map<String, dynamic> j) => PortalSaleDto(
    id:             j['id'] as int,
    title:          j['title'] as String,
    description:    j['description'] as String?,
    imageUrl:       j['imageUrl'] as String?,
    bannerGradient: j['bannerGradient'] as String?,
    startDate:      j['startDate'] != null ? DateTime.tryParse(j['startDate'] as String) : null,
    endDate:        j['endDate']   != null ? DateTime.tryParse(j['endDate']   as String) : null,
    items:          (j['items'] as List<dynamic>? ?? [])
        .map((e) => PortalSaleItemDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Returns the sale price for this productId, or null if not in this sale.
  double? salePriceFor(int productId) {
    for (final it in items) {
      if (it.productId == productId) return it.salePrice;
    }
    return null;
  }
}
