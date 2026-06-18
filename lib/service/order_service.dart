import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/model/order_dto.dart';
import 'package:mandel_mobile_app/utility/common_utility.dart';
import 'package:mandel_mobile_app/utility/dio_client.dart';

class OrderService with CommonUtility {
  Future<Response> getOrderList(Map<String, dynamic>? filters) async {
    return DioClient().dio.get(buildUrl("/orders"), queryParameters: filters);
  }

  Future<Response> postOrder(OrderDto orderDto) {
    return DioClient().dio.post(buildUrl("/orders"), data: orderDto.toJson());
  }

  Future<Response> submitCartOrder(List<OrderItemEntity> items, String notes) {
    return DioClient().dio.post(buildUrl("/orders"), data: {
      'items': items.map((e) => {'productId': e.productId, 'qty': e.qty ?? 1}).toList(),
      'notes': notes,
    });
  }

  Future<Response> deleteOrder(int orderId) {
    return DioClient().dio.delete(buildUrl("/orders/$orderId"));
  }

  Future<Response> getOrderItems(dynamic orderId) {
    return DioClient().dio.get(buildUrl("/orders/$orderId/items"));
  }
}
