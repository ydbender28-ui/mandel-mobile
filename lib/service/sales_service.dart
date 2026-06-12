import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/model/portal_sale_dto.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class SalesService with AuthSupportUtility {
  Future<List<PortalSaleDto>> getSales() async {
    try {
      final token = await getTokenFromSession();
      final resp  = await Dio().get(
        '${CommonConstants.mandelBaseUrl}/sales',
        options: Options(headers: {
          CommonConstants.authorization: '${CommonConstants.bearer}$token',
        }),
      );
      final data = resp.data as Map<String, dynamic>;
      return (data['sales'] as List<dynamic>? ?? [])
          .map((e) => PortalSaleDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) { return []; }
  }
}
