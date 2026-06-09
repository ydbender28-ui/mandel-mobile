class DealDetailDto {
  String? type;
  double? amount;

  DealDetailDto({this.type, this.amount});

  DealDetailDto.fromJson(Map<String, dynamic> json) {
    type = json['type'];

    if (null != json['price']) {
      amount = json['amount'].toDouble();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = type;
    data['amount'] = amount;
    return data;
  }
}
