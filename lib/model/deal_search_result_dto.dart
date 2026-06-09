import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/meta_dto.dart';

class DealSearchResultDto {
  MetaDto? meta;
  List<DealDto>? results;

  DealSearchResultDto({this.meta, this.results}) {
    results = [];
  }

  DealSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    try {
      if (json['results'] != null) {
        results = <DealDto>[];
        json['results'].forEach((v) {
          results!.add(DealDto.fromJson(v));
        });
      }
    } catch (e) {
      print(e);
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
