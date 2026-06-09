import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class CategoryService with CommonUtility {
  Future<Response> getCategoryList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/category'), queryParameters: filters);
  }

  // Load live from API
  Future<List<CategoryDto>> getAllCategoryList(Map<String, dynamic>? filters) async {
    final response = await DioClient().dio.get(buildUrl('/category'));
    if (response.data is List) {
      return (response.data as List).map((e) => CategoryDto.fromJson(e)).toList();
    }
    return [];
  }
}
