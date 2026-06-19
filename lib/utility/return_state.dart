import 'dart:async';
import 'dart:convert';
import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReturnState {
  static const _key = 'mandel_return_v1';
  static final List<ReturnItemEntity> _items = [];

  static final StreamController<void> _changes = StreamController.broadcast();
  static Stream<void> get changes => _changes.stream;

  static List<ReturnItemEntity> get items => List.unmodifiable(_items);

  static int get itemCount => _items.length;

  static double get grandTotal =>
      _items.fold(0.0, (sum, i) => sum + (i.subTotal ?? 0));

  static void addOrUpdate(ReturnItemEntity item) {
    final idx = _items.indexWhere((i) => i.productId == item.productId && i.returnType == item.returnType);
    if (idx >= 0) {
      _items[idx] = item;
    } else {
      _items.add(item);
    }
    _save();
    _changes.add(null);
  }

  static void updateQty(int productId, String returnType, int qty) {
    final idx = _items.indexWhere((i) => i.productId == productId && i.returnType == returnType);
    if (idx < 0) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx].qty = qty;
      _items[idx].subTotal = (_items[idx].returnPrice ?? 0) * qty;
    }
    _save();
    _changes.add(null);
  }

  static void removeItem(int productId) {
    _items.removeWhere((i) => i.productId == productId);
    _save();
    _changes.add(null);
  }

  static void clear() {
    _items.clear();
    _save();
    _changes.add(null);
  }

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      _items.clear();
      for (final m in list) {
        _items.add(ReturnItemEntity.fromJson(m as Map<String, dynamic>));
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
