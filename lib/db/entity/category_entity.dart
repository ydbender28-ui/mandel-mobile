import 'dart:convert';

import 'package:mandel_mobile_app/model/category_dto.dart';

const String tableCategories = 'tbl_categories';

class CategoryField {
  static const String id = 'id';
  static const String name = 'name';
  static const String category = 'category';
}

class CategoryEntity {
  int? id;
  String? name;
  String? category;

  CategoryEntity({this.id, this.name, this.category});

  CategoryEntity.fromCategoryDto(CategoryDto categoryDto) {
    id = categoryDto.id;
    name = categoryDto.name;
    category = json.encode(categoryDto.toJson());
  }

  CategoryDto toCategoryDto() {
    return CategoryDto.fromJson(json.decode(category!));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['id'] = id;
    data['name'] = name;
    data['category'] = category;

    return data;
  }
}
