import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/user_dto.dart';

class UserSearchResultDto {
  MetaDto? meta;
  List<UserDto>? results;

  UserSearchResultDto.fromJson(Map<String, dynamic> json) {
    if (json['meta'] != null) {
      meta = MetaDto.fromJson(json['meta']);
    }

    if (json['results'] != null) {
      results = <UserDto>[];
      json['results'].forEach((v) {
        results!.add(UserDto.fromJson(v));
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
