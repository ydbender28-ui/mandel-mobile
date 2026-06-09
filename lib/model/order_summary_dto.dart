class OrderSummaryDto {
  String? category;
  int? qty;

  OrderSummaryDto({this.category, this.qty});

  OrderSummaryDto.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category'] = category;
    data['qty'] = category;
    return data;
  }
}
