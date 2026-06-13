import 'dart:async';
import 'dart:convert';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/service/cart_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartState {
  static const _key = 'mandel_cart_v1';
  static final List<OrderItemEntity> _items = [];
  static Timer? _syncTimer;

  // Broadcast stream — listeners rebuild when cart changes
  static final StreamController<void> _changes = StreamController.broadcast();
  static Stream<void> get changes => _changes.stream;

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
    _scheduleSync();
    _changes.add(null);
  }

  static void removeItem(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    _save();
    _scheduleSync();
    _changes.add(null);
  }

  static void updateQty(int productId, int qty) {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx].qty = qty;
      _items[idx].subTotal = (_items[idx].unitPrice ?? 0) * qty;
    }
    _save();
    _scheduleSync();
    _changes.add(null);
  }

  static void clear() {
    _items.clear();
    _save();
    CartSyncService().clearServerCart();
    _syncTimer?.cancel();
    _changes.add(null);
  }

  // Debounced push: waits 2 s after last change before syncing to server
  static void _scheduleSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(seconds: 2), () {
      CartSyncService().pushCart(_items.toList());
    });
  }

  /// Called on app start after auth: replaces local cart with server cart if server has items.
  static Future<void> loadFromServer() async {
    final serverItems = await CartSyncService().pullCart();
    if (serverItems.isEmpty) return;
    _items.clear();
    for (final item in serverItems) {
      _items.add(OrderItemEntity(
        productId:    item['productId'] as int?,
        productName:  item['productName'] as String?,
        brandName:    item['brandName'] as String?,
        categoryName: item['categoryName'] as String?,
        size:         item['sizeName'] as String?,
        qty:          item['qty'] as int?,
        unitPrice:    (item['unitPrice'] as num?)?.toDouble(),
        subTotal:     (item['subTotal']  as num?)?.toDouble(),
      ));
    }
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
