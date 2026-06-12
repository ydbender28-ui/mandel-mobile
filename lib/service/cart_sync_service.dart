import 'package:dio/dio.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/utility/auth_support_utility.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';

class CartSyncService with AuthSupportUtility {
  static final CartSyncService _instance = CartSyncService._();
  CartSyncService._();
  factory CartSyncService() => _instance;

  Future<void> pushCart(List<OrderItemEntity> items) async {
    try {
      final token = await getTokenFromSession();
      if (token.isEmpty) return;
      await Dio().put(
        '${CommonConstants.mandelBaseUrl}/cart',
        data: {
          'items': items.map((it) => {
            'productId':    it.productId,
            'productName':  it.productName,
            'brandName':    it.brandName,
            'categoryName': it.categoryName,
            'sizeName':     it.size,
            'qty':          it.qty ?? 1,
            'unitPrice':    it.unitPrice ?? 0,
            'subTotal':     it.subTotal  ?? 0,
          }).toList(),
        },
        options: Options(headers: {
          CommonConstants.authorization: '${CommonConstants.bearer}$token',
        }),
      );
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> pullCart() async {
    try {
      final token = await getTokenFromSession();
      if (token.isEmpty) return [];
      final resp = await Dio().get(
        '${CommonConstants.mandelBaseUrl}/cart',
        options: Options(headers: {
          CommonConstants.authorization: '${CommonConstants.bearer}$token',
        }),
      );
      final data = resp.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['items'] as List? ?? []);
    } catch (_) { return []; }
  }

  Future<void> clearServerCart() async {
    try {
      final token = await getTokenFromSession();
      if (token.isEmpty) return;
      await Dio().delete(
        '${CommonConstants.mandelBaseUrl}/cart',
        options: Options(headers: {
          CommonConstants.authorization: '${CommonConstants.bearer}$token',
        }),
      );
    } catch (_) {}
  }
}
