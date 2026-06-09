import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/model/brand_search_result_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class BrandService with CommonUtility {
  // Load live from API
  Future<BrandSearchResultDto> getBrandList(Map<String, dynamic>? filters) async {
    final response = await DioClient().dio.get(buildUrl('/brand'));
    List<BrandDto> brands = [];
    if (response.data is List) {
      brands = (response.data as List).map((e) => BrandDto.fromJson(e)).toList();
    }
    return BrandSearchResultDto(results: brands);
  }
}
