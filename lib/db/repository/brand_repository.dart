import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/brand_entity.dart';
import 'package:mandel_mobile_app/model/brand_dto.dart';
import 'package:sqflite/sqflite.dart';

class BrandRepository {
  Future<void> storeBrands(List<BrandDto> brandList) async {
    try {
      final db = await DBHelper.instance.database;
      Batch batch = db.batch();

      for (var brand in brandList) {
        batch.insert(tableBrands, BrandEntity.fromBrandDto(brand).toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
    } catch (e) {
      throw Error();
    }
  }

  Future<List<BrandDto>> getBrands(Map<String, dynamic>? filters) async {
    try {
      final db = await DBHelper.instance.database;
      String whereClause = "";
      filters?.forEach((key, value) {
        if (whereClause.isNotEmpty) {
          whereClause = '$whereClause AND';
        }
        switch (key) {
          case (BrandField.name):
            whereClause = '$whereClause $key LIKE "%$value%"';
            break;
          default:
            break;
        }
      });
      final List<Map<String, dynamic>> dbResults = await db.query(tableBrands,
          orderBy: 'name ASC',
          where: whereClause.isNotEmpty ? whereClause : null);
      List<BrandDto> brandList = List.generate(
          dbResults.length,
          (index) => BrandEntity(
                  id: dbResults[index][BrandField.id],
                  name: dbResults[index][BrandField.name],
                  brand: dbResults[index][BrandField.brand])
              .toBrandDto());
      return brandList;
    } catch (e) {
      throw Error();
    }
  }
}
