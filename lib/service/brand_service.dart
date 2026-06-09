import 'package:mandel_mobile_app/db/repository/brand_repository.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class BrandService with CommonUtility {
  final BrandRepository repository = BrandRepository();

  ///
  ///This method will return brand list by filter data
  getBrandList(Map<String, dynamic>? filters) {
    // return DioClient().dio.get(buildUrl('/brand'), queryParameters: filters);
    return repository.getBrands(filters);
  }
}
