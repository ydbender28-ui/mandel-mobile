// In-memory implementation — replaces SQLite for web compatibility
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:mandel_mobile_app/utility/cart_state.dart';

class OrderMasterRepository {
  static bool _orderExists = false;
  static String _lastUpdated = '';

  Future<bool> isOrderExist() async => _orderExists;

  Future<int> storeOrderMasterRecode(OrderMasterEntity orderMaster) async {
    _orderExists = true;
    _lastUpdated = orderMaster.updatedDate ?? '';
    return 1;
  }

  Future<int> updateOrderMasterRecode(OrderMasterEntity orderMaster) async {
    _lastUpdated = orderMaster.updatedDate ?? '';
    return 1;
  }

  Future<List<OrderMasterEntity>> getLastUpdatedTimeStamp() async {
    if (!_orderExists) return [];
    return [OrderMasterEntity(id: 1, createdDate: _lastUpdated, updatedDate: _lastUpdated)];
  }

  Future<int> clearOrderMaster() async {
    _orderExists = false;
    _lastUpdated = '';
    CartState.clear();
    return 1;
  }
}
