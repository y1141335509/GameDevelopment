import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelperLevel_01 {
  static final DBHelperLevel_01 _instance = DBHelperLevel_01._internal();
  static Database? _database;
  static String globalSuffix = '_01';
  static String TABLE_NAME = 'LEVEL' + globalSuffix;

  ////////////////////////////////////////////////////////
  ///                   TABLE SCHEMA                   ///
  /// ------------------------------------------------ ///
  ///  FOOD_ID |  FOOD_NAME    YEAR1   YEAR2   YEAR3   ///
  /// ------------------------------------------------ ///
  ///     1    | watermelon      0       1       2     ///
  ///     2    |   apple         2       3       5     ///
  ///     3    |   banana        3       5       6     ///
  /// ------------------------------------------------ ///

  // 私有的命名构造函数
  DBHelperLevel_01._internal();

  // 工厂构造函数
  factory DBHelperLevel_01() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDB();
    return _database!;
  }

  static Future<Database> initializeDB() async {
    String dbPath = await getDatabasesPath();
    print('your database path is:' + dbPath.toString() + ' initialize your db');
    var db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'),
        onCreate: (database, version) async {
      await database.execute(
        """
        CREATE TABLE LEVEL_01
        ('FOOD_ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        '15' VARCHAR(30) NOT NULL,
        '20' VARCHAR(30) NOT NULL,
        '25' VARCHAR(30) NOT NULL,
        '30' VARCHAR(30) NOT NULL
        )""",
      );
      // 导入 CSV 数据
      await importCSVToSQLite(database);
    }, version: 1);
    return db;
  }

  static Future<void> importCSVToSQLite(Database db) async {
    final data = await rootBundle
        .loadString('assets/data/' + TABLE_NAME + '.csv'); // 检查数据表是否已经含有数据
    List<Map> list = await db.rawQuery(
      'SELECT * FROM LEVEL_01',
    );
    if (list.isNotEmpty) {
      // 如果已经含有数据，则清空数据表
      await db.delete(TABLE_NAME);
      // 重置自增 ID：
      await db.rawDelete("DELETE FROM sqlite_sequence WHERE name=LEVEL_01", []);
    }

    // 读取csv，以\t为行分界：
    List<String> lines = data.split('\n');
    print('Number of lines: ${lines.length}');
    for (int i = 1; i < lines.length; i++) {
      // 跳过header
      var row = lines[i].split(',');
      Map<String, dynamic> rowMap = {
        '`15`': row[0], // 使用反引号包裹数字列名
        '`20`': row[1],
        '`25`': row[2],
        '`30`': row[3]
      };
      await db.insert(TABLE_NAME, rowMap);
    }
  }

  // Future<List<String>> queryAllFoodNames() async {
  //   String dbPath = await getDatabasesPath();
  //   final db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'));

  //   final List<Map<String, dynamic>> maps =
  //       await db.query(TABLE_NAME, columns: ['NAME']);
  //   return List.generate(maps.length, (i) {
  //     return maps[i]['NAME'];
  //   });
  // }

  Future<List<Map>> queryAll() async {
    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'));
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT * FROM LEVEL_01
    """,
    );
    return maps;
  }

  // Future<List<Map>> queryFoodNutritionByName(String name) async {
  //   String dbPath = await getDatabasesPath();
  //   final db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'));
  //   final List<Map<String, dynamic>> maps = await db.rawQuery("""
  //       SELECT * FROM food_nutrition
  //       WHERE NAME = ?
  //     """, [name]);
  //   return maps;
  // }

  ///                                      ///
  ///                                      ///
  ////////////////////////////////////////////
}
