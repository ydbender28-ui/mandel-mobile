
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/model/deal_dto.dart';
import 'package:mandel_mobile_app/model/order_item_dto.dart';
import 'package:mandel_mobile_app/model/order_summary_dto.dart';
import 'package:mandel_mobile_app/model/price_dto.dart';
import 'package:mandel_mobile_app/model/price_group_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:sqflite/sqflite.dart';

class OrderRepository {
  ///
  ///This method can be used for store order information
  Future<int> storeOrderItemRecode(OrderItemEntity orderEntity) async {
    final db = await DBHelper.instance.database;
    return await db.insert(tableOrderItem, orderEntity.insetDataToJson());
  }

  ///
  ///This method can be used for update order master information
  Future<int> updateOrderItemRecode(
      OrderItemEntity orderItemEntity, int productId) async {
    final db = await DBHelper.instance.database;
    return await db.update(tableOrderItem, orderItemEntity.insetDataToJson(),
        where: '${OrderItemField.productId} = ?', whereArgs: [productId]);
  }

  ///
  ///This method can be used for update order master information
  Future<int> updateOrderItemQtyRecode(
      OrderItemEntity orderItemEntity, int productId) async {
    final db = await DBHelper.instance.database;
    return await db.update(
        tableOrderItem, orderItemEntity.updateQtyDataToJson(),
        where: '${OrderItemField.productId} = ?', whereArgs: [productId]);
  }

  ///
  ///This method will return item exist
  Future<bool> isAnyItemExist() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableOrderItem''');
    int? result = Sqflite.firstIntValue(sql);

    if (null == result) {
      return false;
    } else {
      return result == 1;
    }
  }

  ///
  ///This method will return item exist
  Future<bool> isItemExist(int productId) async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT CASE COUNT(*) > 0 WHEN 0 THEN 0 ELSE 1 END FROM $tableOrderItem itm where 
        itm.product_id=$productId ''');
    int? result = Sqflite.firstIntValue(sql);

    if (null == result) {
      return false;
    } else {
      return result == 1;
    }
  }

  ///
  ///This method will return item count
  Future<int> getOrderItemCount() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery('''SELECT COUNT(*) FROM $tableOrderItem''');
    int? result = Sqflite.firstIntValue(sql);
    if (null == result) {
      return 0;
    } else {
      return result;
    }
  }

  ///
  ///This method will return items sub total
  Future<String> getOrderItemsSubTotal() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT IFNULL(SUM(odr.sub_total),0.0) as sub_total FROM $tableOrderItem odr''');
    double result = sql[0]['sub_total'] as double;
    return result.toStringAsFixed(2);
  }

  ///
  ///This method will return order list
  Future<List<OrderItemEntity>> getOrderList() async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableOrderItem);
    return List.generate(
      maps.length,
      (index) => OrderItemEntity(
          productId: maps[index][OrderItemField.productId],
          productName: maps[index][OrderItemField.productName],
          categoryName: maps[index][OrderItemField.categoryName],
          size: maps[index][OrderItemField.size],
          qty: maps[index][OrderItemField.qty],
          unitPrice: maps[index][OrderItemField.unitPrice],
          subTotal: maps[index][OrderItemField.subTotal],
          discount: maps[index][OrderItemField.discount]),
    );
  }

  ///
  ///This method will return order list
  Future<List<OrderItem>> getOrderItemList() async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableOrderItem);
    return List.generate(
      maps.length,
      (index) => OrderItem(
          product: ProductDto(id: maps[index][OrderItemField.productId]),
          quantity: maps[index][OrderItemField.qty],
          unitPrice: maps[index][OrderItemField.unitPrice],
          price: maps[index][OrderItemField.subTotal],
          deal: DealDto(id: maps[index][OrderItemField.deal]),
          productPrice: PriceDto(
              productId: maps[index][OrderItemField.productId],
              priceGroupId: maps[index][OrderItemField.priceGroup])),
    );
  }

  ///
  ///This method will return order item by product id
  Future<OrderItemEntity> getOrderItemByProductId(int productId) async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT * FROM $tableOrderItem odr WHERE odr.product_id=$productId''');
    if (maps.isNotEmpty) {
      var map = maps.first;
      return OrderItemEntity(
        productId: map[OrderItemField.productId],
        productName: map[OrderItemField.productName],
        size: map[OrderItemField.size],
        qty: map[OrderItemField.qty],
        unitPrice: map[OrderItemField.unitPrice],
        subTotal: map[OrderItemField.subTotal],
      );
    } else {
      return OrderItemEntity(qty: 1);
    }
  }

  ///
  ///This method will return order item qty by product id
  Future<OrderItemEntity> getOrderItemQtyByProductId(int productId) async {
    final db = await DBHelper.instance.database;
    final sql = await db.rawQuery(
        '''SELECT * FROM $tableOrderItem odr WHERE odr.product_id=$productId''');
    if (sql.isNotEmpty) {
      return OrderItemEntity(
        qty: sql[0][OrderItemField.qty] as int,
      );
    } else {
      return OrderItemEntity(qty: 1);
    }
  }

  ///
  ///This method will return category wise summary
  Future<List<OrderSummaryDto>> getCategoryWiseSummary() async {
    final db = await DBHelper.instance.database;
    var sql = await db
        .rawQuery('''SELECT odr.category_name,IFNULL(SUM(odr.qty),0) as total 
        FROM $tableOrderItem odr GROUP BY odr.category_name''');
    return List.generate(
      sql.length,
      (index) => OrderSummaryDto(
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
        '''SELECT IFNULL(SUM(odr.sub_total),0.0)+(IFNULL(SUM(odr.discount),0.0)*IFNULL(odr.qty,0)) as sub_total FROM $tableOrderItem odr''');

    double value = sql[0]['sub_total'] as double;
    return value.toStringAsFixed(2);
  }

  ///
  ///This method will return order discount
  Future<String> getDiscount() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT IFNULL(SUM(odr.discount),0.0)*IFNULL(odr.qty,0.0) as discount FROM $tableOrderItem odr''');

    double value = sql[0]['discount'] as double;
    return value.toStringAsFixed(2);
  }

  ///
  ///This method will return grand total
  Future<String> getFormattedGrandTotal() async {
    final db = await DBHelper.instance.database;
    var sql = await db
        .rawQuery('''SELECT IFNULL(SUM(odr.sub_total),0.0) as grand_total 
        FROM $tableOrderItem odr''');

    double grandTotal = sql[0]['grand_total'] as double;
    return grandTotal.toStringAsFixed(2);
  }

  ///
  ///This method will return grand total
  Future<double> getPeoGrandTotal() async {
    final db = await DBHelper.instance.database;
    var sql = await db.rawQuery(
        '''SELECT (IFNULL(SUM(odr.sub_total),0.0)-IFNULL(SUM(odr.discount),0.0)) as grand_total 
        FROM $tableOrderItem odr''');
    return sql[0]['grand_total'] as double;
  }

  ///
  ///This method can be used for delete item
  Future<int> deleteItem(int productId) async {
    final db = await DBHelper.instance.database;
    return await db.delete(tableOrderItem,
        where: '${OrderItemField.productId} = ?', whereArgs: [productId]);
  }

  ///
  ///This method can be used for clear order items
  Future<int> clearOrderItems() async {
    try {
      final db = await DBHelper.instance.database;
      return await db.delete(tableOrderItem);
    } catch (e) {
      debugPrint(e);
    }
    return 0;
  }
}
