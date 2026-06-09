import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mandel_mobile_app/service/navigation_service.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class DioClient with AuthSupportUtility {
  final dio = Dio();

  DioClient() {
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) {
      if (status == 401) {
        return false;
      } else {
        return true;
      }
    };

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String token = await getTokenFromSession();
        options.headers[CommonConstants.authorization] =
            CommonConstants.bearer + token;

        debugPrint(
            'REQUEST[${options.method}] => PATH: ${options.path} ${options.uri}');
        ////////////////////////////
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        ////////////////////////////
        return handler.next(response);
      },
      onError: (DioException err, handler) {
        if (null != err.response) {
          if (err.response!.statusCode == 401) {
            final ctx = NavigationService.navigatorKey.currentContext;
            if (ctx != null) {
              Navigator.of(ctx).pushNamed(CommonConstants.loginScreenUrl);
            }
          }
        }
        return handler.next(err);
      },
    ));
  }
}
