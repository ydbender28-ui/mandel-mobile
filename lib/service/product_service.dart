import 'package:mandel_mobile_app/db/repository/product_repository.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class ProductService with CommonUtility {
  final ProductRepository productRepository = ProductRepository();

  ///
  ///This method will return product list by filter data
  getProductList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/product'), queryParameters: filters);
  }

  searchProduct(Map<String, dynamic>? filters, int? page, int? pageSize) {
    return productRepository.searchProduct(filters, page, pageSize);
  }
}
