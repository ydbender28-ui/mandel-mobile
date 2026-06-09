import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class UserService with CommonUtility {
  Future<Response> getUser(String cognitoId) async {
    Map<String, dynamic> queryParams = {
      'pageSize': 1,
      'page': 0,
      'cognitoId': cognitoId
    };

    return DioClient().dio.get(buildUrl('/user'), queryParameters: queryParams);
  }
}
