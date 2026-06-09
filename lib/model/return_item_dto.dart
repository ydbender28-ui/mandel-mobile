import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';

class ReturnItemDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? status;
  String? returnStatus;
  String? returnReason;
  String? note;
  int? quantity;
  double? unitPrice;
  ProductDto? product;
  OrderDto? order;
  double? returnPrice;
  String? returnType;

  ReturnItemDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.status,
      this.returnStatus,
      this.returnReason,
      this.note,
      this.quantity,
      this.unitPrice,
      this.product,
      this.order,
      this.returnPrice,
      this.returnType});

  ReturnItemDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    status = json['status'];
    returnStatus = json['returnStatus'];
    returnReason = json['returnReason'];
    note = json['note'];
    quantity = json['quantity'];
    unitPrice = json['unitPrice'].toDouble();
    returnPrice = json['returnPrice'].toDouble();
    returnType = json['returnType'];

    if (json['product'] != null) {
      product = ProductDto.fromJson(json['product']);
    }

    if (json['order'] != null) {
      order = OrderDto.fromJson(json['order']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;

    if (null != createdDateTime) {
      data['createdDateTime'] = createdDateTime!.toIso8601String();
    }

    if (null != lastChangedDateTime) {
      data['lastChangedDateTime'] = lastChangedDateTime!.toIso8601String();
    }

    if (null != status) {
      data['status'] = status;
    }

    data['returnStatus'] = returnStatus;
    data['returnReason'] = returnReason;
    data['note'] = note;
    data['quantity'] = quantity;
    data['unitPrice'] = unitPrice;
    data['returnPrice'] = returnPrice;
    data['returnType'] = returnType;

    if (product != null) {
      data['product'] = product!.toJson();
    }

    if (order != null) {
      data['order'] = order!.toJson();
    }

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
