import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/size_dto.dart';

class SizeSearchResultDto {
  MetaDto? meta;
  List<SizeDto>? results;

  SizeSearchResultDto({this.meta, this.results}) {
    if (results!.isEmpty) {
      results = [];
    }
  }

  SizeSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <SizeDto>[];
      json['results'].forEach((v) {
        results!.add(SizeDto.fromJson(v));
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
