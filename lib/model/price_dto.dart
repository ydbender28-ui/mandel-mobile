import 'package:mandel_mobile_app/model/deal_dto.dart';

class PriceDto {
  int? productId;
  int? priceGroupId;
  double? price;
  DealDto? deal;

  PriceDto({this.productId, this.priceGroupId, this.price, this.deal});

  PriceDto.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    priceGroupId = json['priceGroupId'];
    price = json['price'].toDouble();

    if (json['deal'] != null) {
      deal = DealDto.fromJson(json['deal']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productId'] = productId;
    data['priceGroupId'] = priceGroupId;
    data['price'] = price;

    if (deal != null) {
      data['deal'] = deal!.toJson();
    }

    return data;
  }

  bool isDealExist() {
    if (null == deal) {
      return false;
    }
    return true;
  }

  double getPrice() {
    if (isDealExist()) {
      return deal!.price ?? 0.0;
    }
    return price ?? 0.0;
  }

  double getNonDiscountedPrice() {
    return price ?? 0.0;
  }

  double getDiscount() {
    if (isDealExist()) {
      return deal!.amount ?? 0.0;
    }
    return 0.0;
  }
}
