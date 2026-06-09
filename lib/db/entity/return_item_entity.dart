const String tableReturnItem = 'tbl_return_item';

class ReturnItemField {
  static const String id = 'id';
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String categoryName = 'category_name';
  static const String brandName = 'brand_name';
  static const String size = 'size';
  static const String unitPrice = 'unit_price';
  static const String returnPrice = 'return_price';
  static const String subTotal = 'sub_total';
  static const String qty = 'qty';
  static const String discount = 'discount';
  static const String returnMasterId = 'return_master_id';
  static const String returnReason = 'return_reason';
  static const String returnType = 'return_type';

  static final List<String> columns = [
    id,
    productId,
    productName,
    categoryName,
    brandName,
    size,
    unitPrice,
    returnPrice,
    subTotal,
    qty,
    discount,
    returnMasterId,
    returnReason,
    returnType
  ];
}

class ReturnItemEntity {
  int? id;
  int? productId;
  String? productName;
  String? categoryName;
  String? brandName;
  String? size;
  double? unitPrice;
  double? returnPrice;
  double? subTotal;
  int? qty;
  double? discount;
  int? returnMasterId;
  String? returnReason;
  String? returnType;

  ReturnItemEntity(
      {this.id,
      this.productId,
      this.productName,
      this.categoryName,
      this.brandName,
      this.size,
      this.unitPrice,
      this.returnPrice,
      this.subTotal,
      this.qty,
      this.discount,
      this.returnMasterId,
      this.returnReason,
      this.returnType});

  ReturnItemEntity.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    size = json['size'];
    unitPrice = json['unit_price'];
    returnPrice = json['return_price'];
    subTotal = json['sub_total'];
    discount = json['discount'];
    qty = json['qty'];
    returnReason = json['returnReason'];
    returnType = json['returnType'];
  }

  Map<String, dynamic> insetDataToJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['category_name'] = categoryName;
    data['brand_name'] = brandName;
    data['size'] = size;
    data['unit_price'] = unitPrice;
    data['return_price'] = returnPrice;
    data['sub_total'] = subTotal;
    data['qty'] = qty;
    data['discount'] = discount;
    data['return_master_id'] = returnMasterId;
    data['return_type'] = returnType;
    data['return_reason'] = returnReason;
    return data;
  }

  Map<String, dynamic> updateQtyDataToJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sub_total'] = subTotal;
    data['qty'] = qty;
    return data;
  }

  String getUnitPrice() {
    double price = unitPrice ?? 0.0;
    return price.toStringAsFixed(2);
  }
}
