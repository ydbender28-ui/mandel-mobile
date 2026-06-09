import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class InvoiceService with CommonUtility {
  Future<Response> getInvoices(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl("/invoice"), queryParameters: filters);
  }
}
