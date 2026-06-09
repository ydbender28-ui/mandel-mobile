import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class ProductService with CommonUtility {
  // Load products live from API — no local DB needed
  Future<ProductSearchResultDto> searchProduct(
      Map<String, dynamic>? filters, int? page, int? pageSize) async {
    final params = <String, dynamic>{
      'page': page ?? 0,
      'pageSize': pageSize ?? 20,
    };
    if (filters != null) {
      if (filters['productName'] != null && filters['productName'].toString().isNotEmpty) {
        params['q'] = filters['productName'];
      }
      if (filters['categoryId'] != null) params['category'] = filters['categoryId'];
      if (filters['brandId'] != null) params['brand'] = filters['brandId'];
    }
    final response = await DioClient().dio.get(buildUrl('/product'), queryParameters: params);
    return ProductSearchResultDto.fromJson(response.data);
  }

  getProductList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/product'), queryParameters: filters);
  }
}
