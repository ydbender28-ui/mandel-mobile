import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/product_entity.dart';
import 'package:mandel_mobile_app/model/meta_dto.dart';
import 'package:mandel_mobile_app/model/product_dto.dart';
import 'package:mandel_mobile_app/model/product_search_result_dto.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepository {
  Future<void> storeProducts(List<ProductDto> products) async {
    try {
      final db = await DBHelper.instance.database;
      await db.rawDelete('DELETE FROM $tableProducts ');
      Batch batch = db.batch();
      final noPriceProducts =
          products.where((element) => element.price!.isEmpty).toList();
      safePrint(noPriceProducts.length);
      for (var element in products) {
        batch.insert(
            tableProducts, ProductEntity.fromProudctDto(element).toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
    } catch (e) {
      safePrint(e);
    }
  }

  Future<ProductSearchResultDto> searchProduct(
      Map<String, dynamic>? filters, int? page, int? pageSize) async {
    try {
      final db = await DBHelper.instance.database;
      String whereClause = "";
      filters?.forEach((String key, dynamic value) {
        if (whereClause.isNotEmpty) {
          whereClause = '$whereClause AND ';
        }
        switch (key) {
          case (ProductField.productName):
            whereClause = '$whereClause $key LIKE "%$value%"';
            break;
          case (ProductField.barcode):
            final filtered = value.toString().replaceAll(RegExp(r'^0{1}'), '');
            whereClause =
                '$whereClause $key LIKE "%$value%" OR $key LIKE "%$filtered%"';
            break;
          case (ProductField.brand || ProductField.category):
            whereClause = '$whereClause $key = "$value"';
            break;
          case (ProductField.isOnDeal || ProductField.isNewItem):
            whereClause = '$whereClause $key = 1';
            break;
          default:
            break;
        }
      });
      final List<Map<String, dynamic>> results = await db.query(tableProducts,
          where: whereClause.isNotEmpty ? whereClause : null,
          limit: pageSize,
          orderBy: 'productName ASC',
          offset: page != null && pageSize != null ? page * pageSize : 0);

      String countQuery = whereClause.isNotEmpty
          ? '''SELECT DISTINCT COUNT(*) FROM $tableProducts WHERE $whereClause'''
          : '''SELECT DISTINCT COUNT(*) FROM $tableProducts''';
      var countResult = await db.rawQuery(countQuery);
      MetaDto meta = MetaDto(
          page: page,
          pageSize: pageSize,
          totalCount: Sqflite.firstIntValue(countResult));
      List<ProductDto> dbResults = List.generate(
          results.length,
          (index) => ProductEntity(
                  id: results[index][ProductField.id],
                  productName: results[index][ProductField.productName],
                  barcode: results[index][ProductField.barcode],
                  product: results[index][ProductField.product])
              .toProductDto());
      return ProductSearchResultDto(results: dbResults, meta: meta);
    } catch (e) {
      throw Error();
    }
  }
}
