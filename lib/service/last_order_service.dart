import 'package:mandel_mobile_app/utility/dio_client.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class LastOrderInfo {
  final int qty;
  final String date;
  const LastOrderInfo({required this.qty, required this.date});
}

class LastOrderService {
  Future<Map<int, LastOrderInfo>> getLastOrders() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('${CommonConstants.mandelBaseUrl}/last-orders');
      if (response.statusCode == 200) {
        final list = (response.data['lastOrders'] as List?) ?? [];
        return {
          for (final e in list)
            (e['productId'] as num).toInt(): LastOrderInfo(
              qty: (e['qty'] as num?)?.toInt() ?? 0,
              date: e['date']?.toString() ?? '',
            )
        };
      }
    } catch (_) {}
    return {};
  }
}
