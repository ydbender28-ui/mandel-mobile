import 'dart:convert';

import 'package:mandel_mobile_app/model/product_dto.dart';

const String tableProducts = 'tbl_products';

class ProductField {
  static const String id = 'id';
  static const String productName = 'productName';
  static const String barcode = 'barcode';
  static const String brand = 'brand';
  static const String category = 'category';
  static const String product = 'product';
  static const String isOnDeal = 'isOnDeal';
  static const String isNewItem = 'isNewItem';
}

class ProductEntity {
  int? id;
  String? productName;
  String? barcode;
  String? brand;
  String? category;
  String? product;
  num? isOnDeal;
  num? isNewItem;

  ProductEntity(
      {this.id,
      this.productName,
      this.barcode,
      this.brand,
      this.category,
      this.isOnDeal,
      this.isNewItem,
      this.product});

  ProductEntity.fromProudctDto(ProductDto productDto) {
    id = productDto.id;
    productName = productDto.productName;
    barcode = productDto.barcodes?.map((e) => e.value).toString();
    brand = productDto.brand?.name;
    category = productDto.category?.name;
    isOnDeal = productDto.deal!.isNotEmpty ? 1 : 0;
    isNewItem = productDto.isNew! ? 1 : 0;
    product = json.encode(productDto.toJson());
  }

  ProductDto toProductDto() {
    return ProductDto.fromJson(json.decode(product!));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['productName'] = productName;
    data['barcode'] = barcode;
    data['product'] = product;
    data['brand'] = brand;
    data['isOnDeal'] = isOnDeal;
    data['isNewItem'] = isNewItem;
    data['category'] = category;

    return data;
  }
}
