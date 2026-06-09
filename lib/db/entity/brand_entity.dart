import 'dart:convert';

import 'package:mandel_mobile_app/model/brand_dto.dart';

const String tableBrands = 'tbl_brands';

class BrandField {
  static const String id = 'id';
  static const String name = 'name';
  static const String brand = 'brand';
}

class BrandEntity {
  int? id;
  String? name;
  String? brand;

  BrandEntity({this.id, this.name, this.brand});

  BrandEntity.fromBrandDto(BrandDto brandDto) {
    id = brandDto.id;
    name = brandDto.name;
    brand = json.encode(brandDto.toJson());
  }

  BrandDto toBrandDto() {
    return BrandDto.fromJson(json.decode(brand!));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['brand'] = brand;

    return data;
  }
}
