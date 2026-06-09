import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class DealsService with CommonUtility {
  ///
  ///This method will return deals list by filter data
  getDealList(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl('/deals'), queryParameters: filters);
  }
}
