import 'dart:convert';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartState {
  static const _key = 'mandel_cart_v1';
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
    _save();
  }

  static void removeItem(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    _save();
  }

  static void clear() {
    _items.clear();
    _save();
  }

  static double get grandTotal =>
      _items.fold(0.0, (sum, i) => sum + (i.subTotal ?? 0));

  static int get itemCount => _items.length;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      _items.clear();
      for (final m in list) {
        _items.add(OrderItemEntity.fromJson(m as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  static void _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((e) => e.insetDataToJson()).toList();
      await prefs.setString(_key, json.encode(list));
    } catch (_) {}
  }
}
