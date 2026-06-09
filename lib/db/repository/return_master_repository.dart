import 'package:flutter/foundation.dart';

import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/return_master_entity.dart';
import 'package:sqflite/sqflite.dart';

class ReturnMasterRepository {
  ///
  ///This method will return last update time stamp of order
  Future<String> getLastUpdatedTimeStamp() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT mst.updated_date as stamp FROM $tableReturnMaster mst WHERE mst.id=1''');

    return sql.isNotEmpty ? sql[0]['stamp'] as String : '';
  }

  Future<bool> isReturnExist() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableReturnMaster mst WHERE mst.id=1 ''');
    int? result = Sqflite.firstIntValue(sql);

    if (null == result) {
      return false;
    } else {
      return result == 1;
    }
  }

  Future<int> storeReturnMasterRecode(
      ReturnMasterEntity returnMasterEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.insert(
          tableReturnMaster, returnMasterEntity.insertDataToJson());
    } catch (e) {
      debugPrint(e.toString());
    }
    return 0;
  }

  Future<int> updateReturnMasterRecode(
      ReturnMasterEntity returnMasterEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.update(
          tableReturnMaster, returnMasterEntity.updateDataToJson(),
          where: '${ReturnMasterField.id} = ?', whereArgs: [1]);
    } catch (e) {
      debugPrint(e.toString());
    }
    return 0;
  }

  ///
  ///This method can be used for delete return
  Future<int> deleteReturn(int returnId) async {
    final db = await DBHelper.instance.database;
    return await db.delete(tableReturnMaster,
        where: '${ReturnMasterField.id} = ?', whereArgs: [returnId]);
  }

  ///
  ///This method can be used for clear order master
  Future<int> clearReturnMaster() async {
    try {
      final db = await DBHelper.instance.database;
      return await db.delete(tableReturnMaster);
    } catch (e) {
      debugPrint(e.toString());
    }
    return 0;
  }
}
