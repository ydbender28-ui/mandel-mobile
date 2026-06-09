import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/model/meta_dto.dart';

class CategorySearchResultDto {
  MetaDto? meta;
  List<CategoryDto>? results;

  CategorySearchResultDto({this.meta, this.results}) {
    if (results!.isEmpty) {
      results = [];
    }
  }

  CategorySearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <CategoryDto>[];
      json['results'].forEach((v) {
        results!.add(CategoryDto.fromJson(v));
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
