import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';

class OrderSearchResultDto {
  MetaDto? meta;
  List<OrderDto>? results;

  OrderSearchResultDto({this.meta, this.results}) {
    results = [];
  }

  OrderSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <OrderDto>[];
      json['results'].forEach((v) {
        results!.add(OrderDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }

    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
