import 'dart:convert';

import 'package:mandel_mobile_app/model/size_dto.dart';

const String tableSize = 'tbl_size';

class SizeField {
  static const String id = 'id';
  static const String name = 'name';
  static const String size = 'size';
}

class SizeEntity {
  int? id;
  String? name;
  String? size;

  SizeEntity({this.id, this.name, this.size});

  SizeEntity.fromSizeDto(SizeDto sizeDto) {
    id = sizeDto.id;
    name = sizeDto.name;
    size = json.encode(sizeDto.toJson());
  }

  SizeDto toCategoryDto() {
    return SizeDto.fromJson(json.decode(size!));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['size'] = size;

    return data;
  }
}
