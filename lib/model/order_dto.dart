import 'package:mandel_mobile_app/model/invoice_dto.dart';
import 'package:mandel_mobile_app/model/media_dto.dart';
import 'package:mandel_mobile_app/model/order_item_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';

class OrderDto {
  int? id;
  UserDto? user;
  String? orderState;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  DateTime? deliveryDate;
  String? notes;
  double? total;
  int? lineCount;
  List<OrderItem>? orderItems;
  String? orderSource;
  InvoiceDto? invoice;

  OrderDto(
      {this.id,
      this.user,
      this.orderState,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.deliveryDate,
      this.notes,
      this.total,
      this.orderItems,
      this.orderSource});

  OrderDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    if (json['user'] != null) {
      user = UserDto.fromJson(json['user']);
    }

    if (json['invoice'] != null) {
      // invoice = MediaDto.fromJson(json['invoice']);
      invoice = InvoiceDto.fromJson(json['invoice']);
    }

    orderState = json['orderState'];

    if (null != json['deliveryDate']) {
      deliveryDate = DateTime.parse(json['deliveryDate']);
    }

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    notes = json['notes'];
    total = json['total'] == null ? 0.0 : json['total'].toDouble();
    lineCount = json['lineCount'] as int?;

    if (json['orderItems'] != null) {
      orderItems = <OrderItem>[];
      json['orderItems'].forEach((v) {
        orderItems!.add(OrderItem.fromJson(v));
      });
    }

    orderSource = json['orderSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;

    if (user != null) {
      data['user'] = user!.toJson();
    }

    data['orderState'] = orderState;

    if (null != deliveryDate) {
      data['deliveryDate'] = deliveryDate!.toIso8601String();
    }

    if (null != createdDateTime) {
      data['createdDateTime'] = createdDateTime!.toIso8601String();
    }

    if (null != lastChangedDateTime) {
      data['lastChangedDateTime'] = lastChangedDateTime!.toIso8601String();
    }

    data['notes'] = notes;
    data['total'] = total;

    if (orderItems != null) {
      data['orderItems'] = orderItems!.map((v) => v.toJson()).toList();
    }

    data['orderSource'] = orderSource;

    data.removeWhere((key, value) => value == null);

    return data;
  }

  ///
  ///This method will return total of order
  String getTotal() {
    double totalAmount = total ?? 0.0;
    return totalAmount.toStringAsFixed(2);
  }
}
