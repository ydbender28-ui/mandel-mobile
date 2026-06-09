import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/news_dto.dart';

class NewsSearchResultDto {
  MetaDto? meta;
  List<NewsDto>? results;

  NewsSearchResultDto({this.meta, this.results}) {
    results = [];
  }

  NewsSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <NewsDto>[];
      json['results'].forEach((v) {
        results!.add(NewsDto.fromJson(v));
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
