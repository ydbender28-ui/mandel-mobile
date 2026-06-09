class ReturnSummaryDto {
  String? category;
  int? qty;

  ReturnSummaryDto({this.category, this.qty});

  ReturnSummaryDto.fromJson(Map<String, dynamic> json) {
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
