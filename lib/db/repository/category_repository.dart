import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/category_entity.dart';
import 'package:mandel_mobile_app/model/category_dto.dart';
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  Future<void> storeCategories(List<CategoryDto> categoryList) async {
    try {
      final db = await DBHelper.instance.database;
      Batch batch = db.batch();

      for (var category in categoryList) {
        batch.insert(
            tableCategories, CategoryEntity.fromCategoryDto(category).toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
    } catch (e) {
      safePrint(e);
    }
  }

  Future<List<CategoryDto>> getCategories(Map<String, dynamic>? filters) async {
    try {
      final db = await DBHelper.instance.database;
      String whereClause = "";
      filters?.forEach((key, value) {
        if (whereClause.isNotEmpty) {
          whereClause = '$whereClause AND';
        }
        switch (key) {
          case (CategoryField.name):
            whereClause = '$whereClause $key LIKE "%$value%"';
            break;
          default:
            break;
        }
      });
      final List<Map<String, dynamic>> results = await db.query(tableCategories,
          orderBy: 'name ASC',
          where: whereClause.isNotEmpty ? whereClause : null);
      List<CategoryDto> dbResults = List.generate(
          results.length,
          (index) => CategoryEntity(
                  id: results[index][CategoryField.id],
                  name: results[index][CategoryField.name],
                  category: results[index][CategoryField.category])
              .toCategoryDto());
      return dbResults;
    } catch (error) {
      throw Error();
    }
  }
}
