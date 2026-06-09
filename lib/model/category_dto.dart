import 'package:mandel_mobile_app/model/media_dto.dart';

class CategoryDto {
  int? id;
  DateTime? createdDateTime;
  DateTime? lastChangedDateTime;
  String? name;
  String? description;
  String? extra;
  List<MediaDto>? media;

  CategoryDto(
      {this.id,
      this.createdDateTime,
      this.lastChangedDateTime,
      this.name,
      this.description,
      this.extra,
      this.media});

  CategoryDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    extra = json['extra'];

    if (null != json['createdDateTime']) {
      createdDateTime = DateTime.parse(json['createdDateTime']);
    }

    if (null != json['lastChangedDateTime']) {
      lastChangedDateTime = DateTime.parse(json['lastChangedDateTime']);
    }

    if (json['media'] != null) {
      media = <MediaDto>[];
      json['media'].forEach((v) {
        media!.add(MediaDto.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    data['name'] = name;
    data['description'] = description;
    data['extra'] = extra;

    // if (null != createdDateTime) {
    //   data['createdDateTime'] = DateFormat('M/d/y').format(createdDateTime!);
    // }

    // if (null != lastChangedDateTime) {
    //   data['lastChangedDateTime'] =
    //       DateFormat('M/d/y').format(lastChangedDateTime!);
    // }

    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
