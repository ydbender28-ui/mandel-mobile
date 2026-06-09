// In-memory implementation — replaces SQLite for web compatibility
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/model/order_item_dto.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';

class OrderRepository {
  Future<int> storeOrderItemRecode(OrderItemEntity orderEntity) async {
    CartState.addItem(orderEntity);
    return 1;
  }

  Future<int> updateOrderItemRecode(OrderItemEntity orderEntity, int productId) async {
    CartState.addItem(orderEntity);
    return 1;
  }

  Future<int> updateOrderItemQtyRecode(int productId, int qty) async {
    final items = CartState.items.toList();
    final idx = items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      final item = items[idx];
      final updated = OrderItemEntity(
        productId: item.productId, productName: item.productName,
        qty: qty, unitPrice: item.unitPrice,
        subTotal: (item.unitPrice ?? 0) * qty,
        discount: item.discount, deal: item.deal,
        priceGroup: item.priceGroup, orderMasterId: item.orderMasterId,
        size: item.size, categoryName: item.categoryName, brandName: item.brandName,
      );
      CartState.addItem(updated);
    }
    return 1;
  }

  Future<bool> isItemExist(int productId) async =>
      CartState.isItemExist(productId);

  Future<int> getOrderItemCount() async => CartState.itemCount;

  Future<String> getOrderItemsSubTotal() async =>
      CartState.grandTotal.toStringAsFixed(2);

  Future<List<OrderItemEntity>> getOrderList() async =>
      CartState.items.toList();

  Future<List<OrderItem>> getOrderItemList() async {
    return CartState.items.map((e) => OrderItem(
      product: null, quantity: e.qty ?? 1,
      unitPrice: e.unitPrice ?? 0,
      subTotal: e.subTotal ?? 0,
    )).toList();
  }

  Future<OrderItemEntity> getOrderItemByProductId(int productId) async {
    return CartState.items.firstWhere(
      (i) => i.productId == productId,
      orElse: () => OrderItemEntity(productId: productId),
    );
  }

  Future<OrderItemEntity> getOrderItemQtyByProductId(int productId) async =>
      getOrderItemByProductId(productId);

  Future<double> getPeoGrandTotal() async => CartState.grandTotal;

  Future<int> clearOrderItems() async {
    CartState.clear();
    return 1;
  }

  Future<int> deleteOrderItem(int productId) async {
    CartState.removeItem(productId);
    return 1;
  }
}
