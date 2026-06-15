import 'package:mandel_mobile_app/model/product_dto.dart';
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
      // Support both 'category' (callers) and 'categoryId' (legacy)
      final cat = filters['category'] ?? filters['categoryId'];
      if (cat != null) params['category'] = cat;
      // Support both 'brand' (callers) and 'brandId' (legacy)
      final brand = filters['brand'] ?? filters['brandId'];
      if (brand != null) params['brand'] = brand;
      if (filters['isNewItem'] == true) params['isNewItem'] = 'true';
      if (filters['isOnSale'] == true) params['isOnSale'] = 'true';
      if (filters['isOnDeal'] == true) params['isOnDeal'] = 'true';
    }
    final response = await DioClient().dio.get(buildUrl('/product'), queryParameters: params);
    return ProductSearchResultDto.fromJson(response.data);
  }

  getProductList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/product'), queryParameters: filters);
  }

  Future<ProductSearchResultDto> getProductById(int productId) async {
    final response = await DioClient().dio.get(buildUrl('/product/$productId'));
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data;
      if (data is Map && data.containsKey('results')) {
        return ProductSearchResultDto.fromJson(data as Map<String, dynamic>);
      }
      final product = ProductDto.fromJson(data as Map<String, dynamic>);
      return ProductSearchResultDto(results: [product]);
    }
    return ProductSearchResultDto(results: []);
  }
}
