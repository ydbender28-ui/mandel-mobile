import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/return_item_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';

class ReturnDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? status;
  UserDto? user;
  List<ReturnItemDto>? returnItems;
  // String? returnStatus;
  // String? returnType;
  // String? returnReason;
  // String? note;
  // int? quantity;
  // double? unitPrice;
  // ProductDto? product;
  // OrderDto? order;
  // UserDto? user;
  // double? returnPrice;

  ReturnDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.status,
      this.user,
      this.returnItems});

  ReturnDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    status = json['status'];

    // returnStatus = json['returnStatus'];
    // returnType = json['returnType'];
    // returnReason = json['returnReason'];
    // note = json['note'];
    // quantity = json['quantity'];
    // unitPrice = json['unitPrice'].toDouble();
    // returnPrice = json['returnPrice'].toDouble();

    // if (json['product'] != null) {
    //   product = ProductDto.fromJson(json['product']);
    // }

    // if (json['order'] != null) {
    //   order = OrderDto.fromJson(json['order']);
    // }

    if (json['user'] != null) {
      user = UserDto.fromJson(json['user']);
    }

    if (json['returnItems'] != null) {
      returnItems = <ReturnItemDto>[];
      json['returnItems'].forEach((v) {
        returnItems!.add(ReturnItemDto.fromJson(v));
      });
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

    // data['returnStatus'] = returnStatus;
    // data['returnType'] = returnType;
    // data['returnReason'] = returnReason;
    // data['note'] = note;
    // data['quantity'] = quantity;
    // data['unitPrice'] = unitPrice;
    // data['returnPrice'] = returnPrice;

    // if (product != null) {
    //   data['product'] = product!.toJson();
    // }

    // if (order != null) {
    //   data['order'] = order!.toJson();
    // }

    data.removeWhere((key, value) => value == null);

    if (user != null) {
      data['user'] = user!.toJson();
    }

    if (returnItems != null) {
      data['returnItems'] = returnItems!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
