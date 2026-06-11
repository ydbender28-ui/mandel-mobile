class InvoiceLineItemDto {
  final String? code;
  final String? name;
  final double qty;
  final double price;
  final double total;

  const InvoiceLineItemDto({
    this.code,
    this.name,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory InvoiceLineItemDto.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItemDto(
      code: json['code']?.toString(),
      name: json['name'],
      qty: (json['qty'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
