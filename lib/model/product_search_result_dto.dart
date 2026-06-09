import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';

class ProductSearchResultDto {
  MetaDto? meta;
  List<ProductDto>? results;

  ProductSearchResultDto({this.meta, this.results}) {
    if (results!.isEmpty) {
      results = [];
    }
  }

  ProductSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <ProductDto>[];
      json['results'].forEach((v) {
        results!.add(ProductDto.fromJson(v));
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
