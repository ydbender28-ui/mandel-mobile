// In-memory cart state — replaces SQLite cart for web compatibility
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';

class CartState {
  static final List<OrderItemEntity> _items = [];

  static List<OrderItemEntity> get items => List.unmodifiable(_items);

  static bool isItemExist(int productId) =>
      _items.any((i) => i.productId == productId);

  static void addItem(OrderItemEntity item) {
    final idx = _items.indexWhere((i) => i.productId == item.productId);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
  }

  static void removeItem(int productId) =>
      _items.removeWhere((i) => i.productId == productId);

  static void clear() => _items.clear();

  static double get grandTotal =>
      _items.fold(0.0, (sum, i) => sum + (i.subTotal ?? 0));

  static int get itemCount => _items.length;
}
