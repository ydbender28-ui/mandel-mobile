
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/user_master_entity.dart';
import 'package:mandel_mobile_app/utility/common_constants.dart';
import 'package:sqflite/sqflite.dart';

class UserMasterRepository {
  ///
  ///This method will return user is exist
  Future<bool> isUserExist() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableUserMaster mst ''');
    int? result = Sqflite.firstIntValue(sql);

    if (sql.isEmpty) {
      return false;
    } else {
      return result! > 0;
    }
  }

  ///
  ///This method can be used for store user master information
  Future<int> storeOrderMasterRecode(UserMasterEntity userMasterEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.insert(tableUserMaster, userMasterEntity.toJson());
    } catch (e) {
      debugPrint(e);
    }
    return 0;
  }

  ///
  ///This method can be used for clear user master
  Future<int> clearUserMaster() async {
    try {
      final db = await DBHelper.instance.database;
      return await db.delete(tableUserMaster);
    } catch (e) {
      debugPrint(e);
    }
    return 0;
  }

  ///
  ///This method can be used for get get name
  Future<String> getUserName() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT  (IFNULL(mst.first_name,'') ||' '||IFNULL(mst.last_name,''))as full_name 
        FROM $tableUserMaster mst LIMIT 1''');
    if (sql.isNotEmpty) {
      return sql[0]['full_name'] as String;
    } else {
      return CommonConstants.emptyRecodeIndicator;
    }
  }

  ///
  ///This method can be used for get current user id
  Future<int> getUserId() async {
    final db = await DBHelper.instance.database;
    var sql = await db
        .rawQuery('''SELECT mst.id FROM $tableUserMaster mst LIMIT 1''');
    return sql[0]['id'] as int;
  }
}
