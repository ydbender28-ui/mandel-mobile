import 'package:mandel_mobile_app/model/media_dto.dart';

class NewsDto {
  int? id;
  String? title;
  String? description;
  List<MediaDto>? media;

  NewsDto({this.id, this.title, this.description, this.media});

  NewsDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];

    if (json['media'] != null) {
      media = <MediaDto>[];
      json['media'].forEach((m) {
        media!.add(MediaDto.fromJson(m));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['title'] = title;
    data['description'] = description;

    if (media != null) {
      data['media'] = media!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}
