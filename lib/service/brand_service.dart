import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class BrandService with CommonUtility {
  // Load live from API — returns List<BrandDto> directly
  Future<List<BrandDto>> getBrandList(Map<String, dynamic>? filters) async {
    final response = await DioClient().dio.get(buildUrl('/brand'));
    if (response.data is List) {
      return (response.data as List).map((e) => BrandDto.fromJson(e)).toList();
    }
    return [];
  }
}
