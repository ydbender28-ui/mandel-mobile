import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class ArService with CommonUtility {
  Future<Response> getLedger({String? from, String? to, String? type}) {
    final Map<String, dynamic> params = {};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (type != null && type.isNotEmpty) params['type'] = type;
    return DioClient().dio.get(
      buildUrl('/ledger'),
      queryParameters: params.isNotEmpty ? params : null,
    );
  }
}
