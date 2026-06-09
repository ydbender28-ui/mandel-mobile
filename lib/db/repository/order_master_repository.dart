import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:sqflite/sqflite.dart';

class OrderMasterRepository {
  ///
  ///This method will return item exist
  Future<bool> isOrderExist() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableOrderMaster mst WHERE mst.id=1 ''');
    int? result = Sqflite.firstIntValue(sql);

    if (null == result) {
      return false;
    } else {
      return result == 1;
    }
  }

  ///
  ///This method will return last update time stamp of order
  Future<String> getLastUpdatedTimeStamp() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT mst.updated_date as stamp FROM $tableOrderMaster mst WHERE mst.id=1''');

    return sql.isNotEmpty ? sql[0]['stamp'] as String : '';
  }

  ///
  ///This method can be used for store order master information
  Future<int> storeOrderMasterRecode(
      OrderMasterEntity orderMasterEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.insert(
          tableOrderMaster, orderMasterEntity.insertDataToJson());
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  ///
  ///This method can be used for update order master information
  Future<int> updateOrderMasterRecode(
      OrderMasterEntity orderMasterEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.update(
          tableOrderMaster, orderMasterEntity.updateDataToJson(),
          where: '${OrderMasterField.id} = ?', whereArgs: [1]);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  ///
  ///This method can be used for delete order
  Future<int> deleteOrder(int orderId) async {
    final db = await DBHelper.instance.database;
    return await db.delete(tableOrderMaster,
        where: '${OrderMasterField.id} = ?', whereArgs: [orderId]);
  }

  ///
  ///This method can be used for clear order master
  Future<int> clearOrderMaster() async {
    try {
      final db = await DBHelper.instance.database;
      return await db.delete(tableOrderMaster);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }
}
