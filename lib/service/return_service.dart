import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/model/return_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class ReturnService with CommonUtility {
  Future<Response> getOrderList(Map<String, dynamic>? filters) async {
    return DioClient()
        .dio
        .get(buildUrl('/product-returns'), queryParameters: filters);
  }

  Future<Response> postReturn(ReturnDto returnDto) {
    return DioClient()
        .dio
        .post(buildUrl('/product-returns'), data: returnDto.toJson());
  }

  Future<Response> getReturnSettings() {
    return DioClient().dio.get(buildUrl('/return-settings'));
  }
}
