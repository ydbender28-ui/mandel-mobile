import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/model/meta_dto.dart';

class BrandSearchResultDto {
  MetaDto? meta;
  List<BrandDto>? results;

  BrandSearchResultDto({this.meta, this.results}) {
    if (results!.isEmpty) {
      results = [];
    }
  }

  BrandSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <BrandDto>[];
      json['results'].forEach((v) {
        results!.add(BrandDto.fromJson(v));
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
