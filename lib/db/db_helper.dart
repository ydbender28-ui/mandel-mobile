import 'package:mandel_mobile_app/db/entity/brand_entity.dart';
import 'package:mandel_mobile_app/db/entity/category_entity.dart';
import 'package:mandel_mobile_app/db/entity/configs_entity.dart';
import 'package:mandel_mobile_app/db/entity/order_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/order_master_entity.dart';
import 'package:mandel_mobile_app/db/entity/product_entity.dart';
import 'package:mandel_mobile_app/db/entity/return_item_entity.dart';
import 'package:mandel_mobile_app/db/entity/return_master_entity.dart';
import 'package:mandel_mobile_app/db/entity/size_entity.dart';
import 'package:mandel_mobile_app/db/entity/user_master_entity.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper.init();

  ///basic info
  static const _databaseName = "mandel.db";
  static const _databaseVersion = 1;

  DBHelper.init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    databaseFactory.deleteDatabase(path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $tableOrderMaster (
          ${OrderMasterField.id} INTEGER NOT NULL,
          ${OrderMasterField.createdDate} TEXT NOT NULL,
          ${OrderMasterField.updatedDate} TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableOrderItem (
          ${OrderItemField.id} INTEGER PRIMARY KEY,
          ${OrderItemField.productId} INTEGER NOT NULL,
          ${OrderItemField.productName} TEXT NOT NULL,
          ${OrderItemField.categoryName} TEXT NULL,
          ${OrderItemField.brandName} TEXT NULL,
          ${OrderItemField.size} TEXT NULL,
          ${OrderItemField.unitPrice} REAL NOT NULL,
          ${OrderItemField.subTotal} REAL NOT NULL,
          ${OrderItemField.qty} INTEGER NOT NULL,
          ${OrderItemField.discount} REAL NULL,
          ${OrderItemField.orderMasterId} INTEGER NOT NULL,
          ${OrderItemField.priceGroup} INTEGER NOT NULL,
          ${OrderItemField.deal} INTEGER NULL,
          FOREIGN KEY(${OrderItemField.orderMasterId}) REFERENCES $tableOrderMaster(${OrderMasterField.id}))''');

    await db.execute('''CREATE TABLE $tableReturnMaster (
          ${ReturnMasterField.id} INTEGER NOT NULL,
          ${ReturnMasterField.createdDate} TEXT NOT NULL,
          ${ReturnMasterField.updatedDate} TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableReturnItem (
          ${ReturnItemField.id} INTEGER PRIMARY KEY,
          ${ReturnItemField.productId} INTEGER NOT NULL,
          ${ReturnItemField.productName} TEXT NOT NULL,
          ${ReturnItemField.categoryName} TEXT NULL,
          ${ReturnItemField.brandName} TEXT NULL,
          ${ReturnItemField.size} TEXT NULL,
          ${ReturnItemField.unitPrice} REAL NOT NULL,
          ${ReturnItemField.returnPrice} REAL NOT NULL,
          ${ReturnItemField.subTotal} REAL NOT NULL,
          ${ReturnItemField.qty} INTEGER NOT NULL,
          ${ReturnItemField.discount} REAL NULL,
          ${ReturnItemField.returnMasterId} INTEGER NOT NULL,
          ${ReturnItemField.returnReason} TEXT NOT NULL,
          ${ReturnItemField.returnType} TEXT NOT NULL,
          FOREIGN KEY(${ReturnItemField.returnMasterId}) REFERENCES $tableReturnMaster(${ReturnItemField.id}))''');

    await db.execute('''CREATE TABLE $tableUserMaster (
          ${UserMasterField.id} INTEGER NOT NULL,
          ${UserMasterField.cognitoId} TEXT NULL,
          ${UserMasterField.userType} TEXT NULL,
          ${UserMasterField.title} TEXT NULL,
          ${UserMasterField.firstName} TEXT NULL,
          ${UserMasterField.middleName} TEXT NULL,
          ${UserMasterField.lastName} TEXT NULL,
          ${UserMasterField.mediaUrl} TEXT NULL,
          ${UserMasterField.status} TEXT NULL)''');

    await db.execute('''CREATE TABLE $tableConfigs (
          ${ConfigsField.id} INTEGER PRIMARY KEY,
          ${ConfigsField.key} TEXT NOT NULL,
          ${ConfigsField.value} TEXT NULL)''');

    await db.execute('''CREATE TABLE $tableProducts (
          ${ProductField.id} INTEGER PRIMARY KEY,
          ${ProductField.productName} TEXT NOT NULL,
          ${ProductField.barcode} TEXT NOT NULL,
          ${ProductField.brand} TEXT  NULL,
          ${ProductField.category} TEXT  NULL,
          ${ProductField.isOnDeal} BOOLEAN,
          ${ProductField.isNewItem} BOOLEAN,
          ${ProductField.product} TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableCategories (
          ${CategoryField.id} INTEGER PRIMARY KEY,
          ${CategoryField.name} TEXT NOT NULL,
          ${CategoryField.category} TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableBrands (
          ${BrandField.id} INTEGER PRIMARY KEY,
          ${BrandField.name} TEXT NOT NULL,
          ${BrandField.brand} TEXT NOT NULL)''');

    await db.execute('''CREATE TABLE $tableSize (
          ${SizeField.id} INTEGER PRIMARY KEY,
          ${SizeField.name} TEXT NOT NULL,
          ${SizeField.size} TEXT NOT NULL)''');
  }
}
