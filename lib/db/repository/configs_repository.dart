import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mandel_mobile_app/db/db_helper.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:sqflite/sqflite.dart';

class ConfigsRepository {
  Future<int> storeConfigs(ConfigsEntity configsEntity) async {
    try {
      final db = await DBHelper.instance.database;
      return await db.insert(tableConfigs, configsEntity.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      safePrint(e);
    }
    return 0;
  }

  Future<List<ConfigsEntity>> getConfigs() async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> results =
        await db.rawQuery('''SELECT * FROM $tableConfigs ''');
    return List.generate(
      results.length,
      (index) => ConfigsEntity(
          id: results[index][ConfigsField.id],
          key: results[index][ConfigsField.key],
          value: results[index][ConfigsField.value]),
    );
  }

  Future<List<ConfigsEntity>> getConfigsyByKey(String key) async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> results = await db
        .rawQuery('''SELECT * FROM $tableConfigs t WHERE t.key=?''', [key]);

    return List.generate(
        results.length,
        (index) => ConfigsEntity(
            id: results[index][ConfigsField.id],
            key: results[index][ConfigsField.key],
            value: results[index][ConfigsField.value]));
  }

  Future<ConfigsEntity> getSingleConfigByKey(String key) async {
    final db = await DBHelper.instance.database;
    final List<Map<String, dynamic>> results = await db
        .rawQuery('''SELECT * FROM $tableConfigs t WHERE t.key=?''', [key]);

    if (results.isEmpty) {
      return ConfigsEntity(id: -1, key: key, value: null);
    }
    return ConfigsEntity(
        id: results.first[ConfigsField.id],
        key: results.first[ConfigsField.key],
        value: results.first[ConfigsField.value]);
  }

  Future<void> removeConfig(String key) async {
    final db = await DBHelper.instance.database;
    await db.rawQuery('''DELETE FROM $tableConfigs WHERE key=?''', [key]);
  }
}
