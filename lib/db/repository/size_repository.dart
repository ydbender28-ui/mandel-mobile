import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/size_entity.dart';
import 'package:mandel_mobile_app/model/size_dto.dart';
import 'package:sqflite/sqflite.dart';

class SizeRepository {
  Future<void> storeSize(List<SizeDto> sizeList) async {
    try {
      final db = await DBHelper.instance.database;
      Batch batch = db.batch();

      for (var size in sizeList) {
        batch.insert(tableSize, SizeEntity.fromSizeDto(size).toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit();
    } catch (e) {
      throw Error();
    }
  }

  Future<List<SizeDto>> getSize() async {
    try {
      final db = await DBHelper.instance.database;
      final List<Map<String, dynamic>> results =
          await db.query(tableSize, orderBy: 'name ASC');
      List<SizeDto> dbResults = List.generate(
          results.length,
          (index) => SizeEntity(
                  id: results[index][SizeField.id],
                  name: results[index][SizeField.name],
                  size: results[index][SizeField.size])
              .toCategoryDto());
      return dbResults;
    } catch (error) {
      throw Error();
    }
  }
}
