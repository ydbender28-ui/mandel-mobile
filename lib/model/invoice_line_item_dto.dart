class InvoiceLineItemDto {
  final int? rowNum;
  final String? code;
  final String? name;
  final String? upc;
  final String? ptype;
  final double qty;
  final double price;
  final double total;

  const InvoiceLineItemDto({
    this.rowNum,
    this.code,
    this.name,
    this.upc,
    this.ptype,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory InvoiceLineItemDto.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItemDto(
      rowNum: json['rowNum'] != null
          ? (json['rowNum'] is int
              ? json['rowNum'] as int
              : int.tryParse(json['rowNum'].toString()))
          : null,
      code: json['code']?.toString(),
      name: json['name'],
      upc: json['upc']?.toString(),
      ptype: json['ptype']?.toString(),
      qty: (json['qty'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
