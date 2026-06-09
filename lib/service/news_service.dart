import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class NewsService with CommonUtility {
  Future<Response> getNews(Map<String, dynamic>? filters) {
    return DioClient().dio.get(buildUrl("/news"), queryParameters: filters);
  }
}
