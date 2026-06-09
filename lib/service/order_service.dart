import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class OrderService with CommonUtility {
  Future<Response> getOrderList(Map<String, dynamic>? filters) async {
    return DioClient().dio.get(buildUrl("/order"), queryParameters: filters);
  }

  Future<Response> postOrder(OrderDto orderDto) {
    return DioClient().dio.post(buildUrl("/order"), data: orderDto.toJson());
  }

  Future<Response> deleteOrder(int orderId) {
    return DioClient().dio.delete(buildUrl("/order/$orderId"));
  }
}
