import 'package:mandel_mobile_app/model/portal_ad_dto.dart';
import 'package:mandel_mobile_app/model/portal_deal_dto.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

String _buildUrl(String path) => '${CommonConstants.mandelBaseUrl}$path';

class AdsService {
  Future<List<PortalAdDto>> getAds() async {
    try {
      final r = await DioClient().dio.get(_buildUrl('/ads'));
      final data = r.data;
      if (data is Map && data['ads'] is List) {
        return (data['ads'] as List)
            .map((e) => PortalAdDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<PortalDealDto>> getDeals() async {
    try {
      final r = await DioClient().dio.get(_buildUrl('/deals'));
      final data = r.data;
      if (data is Map && data['deals'] is List) {
        return (data['deals'] as List)
            .map((e) => PortalDealDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
