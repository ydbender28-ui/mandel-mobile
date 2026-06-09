import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/price_group_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class OrderItem {
  ProductDto? product;
  int? quantity;
  double? price;
  double? unitPrice;
  int? tempQty;
  PriceDto? productPrice;
  DealDto? deal;

  OrderItem(
      {this.product,
      this.quantity,
      this.price,
      this.unitPrice,
      this.productPrice,
      this.deal});

  OrderItem.fromJson(Map<String, dynamic> json) {
    if (json['product'] != null) {
      product = ProductDto.fromJson(json['product']);
    }

    if (json['price'] != null) {
      price = json['price'].toDouble();
    }

    if (json['unitPrice'] != null) {
      unitPrice = json['unitPrice'].toDouble();
    }

    if (json['productPrice'] != null) {
      productPrice = PriceDto.fromJson(json['productPrice']);
    }

    if (json['deal'] != null) {
      deal = DealDto.fromJson(json['deal']);
    }

    quantity = json['quantity'];

    tempQty = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['quantity'] = quantity;
    data['price'] = price;
    data['unitPrice'] = unitPrice;
    if (deal != null) {
      data['deal'] = deal!.toJson();
    }
    if (productPrice != null) {
      data['productPrice'] = productPrice!.toJson();
    }
    return data;
  }

  ///
  ///This method will return productId
  int getProductId() {
    if (null == product) {
      return 0;
    }

    if (null == product!.id) {
      return 0;
    }

    return product!.id!;
  }

  ///
  ///This method will return product name
  String getProductName() {
    if (null == product) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.productName) {
      return CommonConstants.emptyRecodeIndicator;
    }

    return product!.productName!;
  }

  ///
  ///This method will return category name
  String getCategoryName() {
    if (null == product) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.category) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.category!.name) {
      return CommonConstants.emptyRecodeIndicator;
    }

    return product!.category!.name!;
  }

  ///
  ///This method will return brand name
  String getBrandName() {
    if (null == product) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.brand) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.brand!.name) {
      return CommonConstants.emptyRecodeIndicator;
    }

    return product!.brand!.name!;
  }

  ///
  ///This method will return size name
  String getSize() {
    if (null == product) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.size) {
      return CommonConstants.emptyRecodeIndicator;
    }

    if (null == product!.size!.name) {
      return CommonConstants.emptyRecodeIndicator;
    }

    return product!.size!.name!;
  }

  ///
  ///This method will return unit price
  String getUnitPrice() {
    double price = (unitPrice ?? 0.0);
    return price.toStringAsFixed(2);
  }

  ///
  ///
  double getNonFormattedUnitPrice() {
    return (unitPrice ?? 0.0);
  }

  ///
  ///This method will return sub total of item
  String getSubTotal() {
    double subTotal = (unitPrice ?? 0.0) * (quantity ?? 0);
    return subTotal.toStringAsFixed(2);
  }

  double getNonFormattedSubTotal() {
    double subTotal = (unitPrice ?? 0.0) * (quantity ?? 0);
    return subTotal;
  }
}
