import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/db/repository/category_repository.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class CategoryService with CommonUtility {
  final CategoryRepository repository = CategoryRepository();

  ///
  ///This method will return all category list
  Future<Response> getCategoryList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/category'), queryParameters: filters);
  }

  Future<List<CategoryDto>> getAllCategoryList(Map<String, dynamic>? filters) {
    // return DioClient().dio.get(buildUrl('/category'));
    return repository.getCategories(filters);
  }
}
