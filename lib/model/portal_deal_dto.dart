class PortalDealItemDto {
  final int id;
  final int? productId;
  final String? refValue;

  const PortalDealItemDto({required this.id, this.productId, this.refValue});

  factory PortalDealItemDto.fromJson(Map<String, dynamic> j) => PortalDealItemDto(
    id:        j['id'] as int,
    productId: j['productId'] as int?,
    refValue:  j['refValue'] as String?,
  );
}

class PortalDealDto {
  final int id;
  final String title;
  final String? description;
  final String type;          // PRODUCT | BRAND | BULK | CATEGORY
  final String discountType;  // PERCENT | FIXED
  final double discountAmount;
  final int? minQty;
  final String? badgeText;
  final DateTime? endDate;
  final List<PortalDealItemDto> items;

  const PortalDealDto({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.discountType,
    required this.discountAmount,
    this.minQty,
    this.badgeText,
    this.endDate,
    this.items = const [],
  });

  factory PortalDealDto.fromJson(Map<String, dynamic> j) => PortalDealDto(
    id:             j['id'] as int,
    title:          j['title'] as String,
    description:    j['description'] as String?,
    type:           (j['type'] as String?) ?? 'PRODUCT',
    discountType:   (j['discountType'] as String?) ?? 'PERCENT',
    discountAmount: ((j['discountAmount'] ?? 0) as num).toDouble(),
    minQty:         j['minQty'] as int?,
    badgeText:      j['badgeText'] as String?,
    endDate:        j['endDate'] != null ? DateTime.tryParse(j['endDate'] as String) : null,
    items:          (j['items'] as List<dynamic>? ?? [])
        .map((e) => PortalDealItemDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// Returns the badge label to show on products (e.g. "20% OFF").
  String get badge {
    if (badgeText != null && badgeText!.isNotEmpty) return badgeText!;
    return discountType == 'PERCENT'
        ? '${discountAmount.toStringAsFixed(discountAmount % 1 == 0 ? 0 : 1)}% OFF'
        : '\$${discountAmount.toStringAsFixed(2)} OFF';
  }

  /// Returns true if this deal applies to the given product.
  bool appliesTo({required int productId, required String brandName, required String category, int qty = 1}) {
    if (type == 'PRODUCT') {
      return items.any((i) => i.productId == productId);
    } else if (type == 'BRAND') {
      return items.any((i) => i.refValue?.toUpperCase() == brandName.toUpperCase());
    } else if (type == 'CATEGORY') {
      return items.any((i) => i.refValue?.toUpperCase() == category.toUpperCase());
    } else if (type == 'BULK') {
      if (minQty != null && qty < minQty!) return false;
      return items.any((i) => i.productId == productId ||
          (i.refValue?.toUpperCase() == brandName.toUpperCase()));
    }
    return false;
  }
}
