const String tableOrderItem = 'tbl_order_item';

class OrderItemField {
  static const String id = 'id';
  static const String productId = 'product_id';
  static const String productName = 'product_name';
  static const String categoryName = 'category_name';
  static const String brandName = 'brand_name';
  static const String size = 'size';
  static const String unitPrice = 'unit_price';
  static const String subTotal = 'sub_total';
  static const String qty = 'qty';
  static const String discount = 'discount';
  static const String orderMasterId = 'order_master_id';
  static const String priceGroup = 'price_group';
  static const String deal = 'deal';

  static final List<String> columns = [
    id,
    productId,
    productName,
    categoryName,
    brandName,
    size,
    unitPrice,
    subTotal,
    qty,
    discount,
    orderMasterId,
    priceGroup,
    deal
  ];
}

class OrderItemEntity {
  int? id;
  int? productId;
  String? productName;
  String? categoryName;
  String? brandName;
  String? size;
  double? unitPrice;
  double? subTotal;
  int? qty;
  double? discount;
  int? orderMasterId;
  int? priceGroup;
  int? deal;

  OrderItemEntity(
      {this.id,
      this.productId,
      this.productName,
      this.categoryName,
      this.brandName,
      this.size,
      this.unitPrice,
      this.subTotal,
      this.qty,
      this.discount,
      this.orderMasterId,
      this.priceGroup,
      this.deal});

  OrderItemEntity.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productName = json['product_name'];
    categoryName = json['category_name'];
    brandName = json['brand_name'];
    size = json['size'];
    unitPrice = json['unit_price'];
    subTotal = json['sub_total'];
    discount = json['discount'];
    qty = json['qty'];
    priceGroup = json['price_group'];
    deal = json['deal'];
  }

  Map<String, dynamic> insetDataToJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['category_name'] = categoryName;
    data['brand_name'] = brandName;
    data['size'] = size;
    data['unit_price'] = unitPrice;
    data['sub_total'] = subTotal;
    data['qty'] = qty;
    data['discount'] = discount;
    data['order_master_id'] = orderMasterId;
    data['price_group'] = priceGroup;
    data['deal'] = deal;
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
