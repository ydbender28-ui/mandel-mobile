import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/model/return_summary_dto.dart';
import 'package:sqflite/sqflite.dart';

class ReturnItemRepository {
  ///
  ///This method will return order list
  Future<List<ReturnItemEntity>> getReturnList() async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableReturnItem);
    return List.generate(
      maps.length,
      (index) => ReturnItemEntity(
          productId: maps[index][ReturnItemField.productId],
          productName: maps[index][ReturnItemField.productName],
          categoryName: maps[index][ReturnItemField.categoryName],
          size: maps[index][ReturnItemField.size],
          qty: maps[index][ReturnItemField.qty],
          unitPrice: maps[index][ReturnItemField.unitPrice],
          subTotal: maps[index][ReturnItemField.subTotal],
          returnReason: maps[index][ReturnItemField.returnReason],
          returnType: maps[index][ReturnItemField.returnType],
          returnPrice: maps[index][ReturnItemField.returnPrice]),
    );
  }

  ///
  ///This method can be used for delete item
  Future<int> deleteItem(int productId) async {
    final db = await DBHelper.instance.database;
    return await db.delete(tableReturnItem,
        where: '${ReturnItemField.productId} = ?', whereArgs: [productId]);
  }

  ///
  ///This method can be used for update order master information
  Future<int> updateReturnItemQtyRecode(
      ReturnItemEntity returnItemEntity, int productId) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.update(
          tableReturnItem, returnItemEntity.updateQtyDataToJson(),
          where: '${ReturnItemField.productId} = ?', whereArgs: [productId]);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  ///
  ///This method will return item exist
  Future<bool> isItemExist(int productId, String returnType) async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableReturnItem itm where 
        itm.product_id=$productId and itm.return_type="$returnType" ''');
    int? result = Sqflite.firstIntValue(sql);

    if (null == result) {
      return false;
    } else {
      return result == 1;
    }
  }

  ///
  ///This method can be used for store order information
  Future<int> storeReturnItemRecode(ReturnItemEntity returnItemEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.insert(
          tableReturnItem, returnItemEntity.insetDataToJson());
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  ///
  ///This method can be used for update order master information
  Future<int> updateReturnItemRecode(
      ReturnItemEntity returnItemEntity, int productId) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.update(
          tableReturnItem, returnItemEntity.insetDataToJson(),
          where: '${ReturnItemField.productId} = ?', whereArgs: [productId]);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  ///
  ///This method will return category wise summary
  Future<List<ReturnSummaryDto>> getCategoryWiseSummary() async {
    final db = await DBHelper.instance.database;
    var sql = await db
        .rawQuery('''SELECT odr.category_name,IFNULL(SUM(odr.qty),0) as total 
        FROM $tableReturnItem odr GROUP BY odr.category_name''');
    return List.generate(
      sql.length,
      (index) => ReturnSummaryDto(
        category: sql[index]['category_name'] as String,
        qty: sql[index]['total'] as int,
      ),
    );
  }

  ///
  ///This method will return order sub total
  Future<String> getSubTotal() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT IFNULL(SUM(odr.sub_total),0.0) as sub_total FROM $tableReturnItem odr''');

    double value = sql[0]['sub_total'] as double;
    return value.toStringAsFixed(2);
  }

  ///
  ///This method will return order discount
  Future<String> getDiscount() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT IFNULL(SUM(odr.discount),0.0) as discount FROM $tableReturnItem odr''');

    double value = sql[0]['discount'] as double;
    return value.toStringAsFixed(2);
  }

  ///
  ///This method will return grand total
  Future<String> getFormattedGrandTotal() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT (IFNULL(SUM(odr.sub_total),0.0)-IFNULL(SUM(odr.discount),0.0)) as grand_total 
        FROM $tableReturnItem odr''');

    double grandTotal = sql[0]['grand_total'] as double;
    return grandTotal.toStringAsFixed(2);
  }

  ///
  ///This method can be used for clear order items
  Future<int> clearReturnItems() async {
    try {
      final db = await DBHelper.instance.database;
      return await db.delete(tableReturnItem);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }
}
