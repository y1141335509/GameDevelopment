import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelperLevel_04 {
  static final DBHelperLevel_04 _instance = DBHelperLevel_04._internal();
  static Database? _database;
  static String globalSuffix = '_04';
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
  DBHelperLevel_04._internal();

  // 工厂构造函数
  factory DBHelperLevel_04() {
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
        CREATE TABLE LEVEL_04 (
          'FOOD_ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          'FOOD_NAME' VARCHAR(100) NOT NULL,
          'YEAR_15' INTEGER NOT NULL,
          'YEAR_20' INTEGER NOT NULL,
          'YEAR_25' INTEGER NOT NULL,
          'YEAR_30' INTEGER NOT NULL)
        """,
      );
    }, version: 1);
    return db;
  }

  static Future<void> importCSVToSQLite(Database db) async {
    List<Map> list = await db.rawQuery(
      'SELECT * FROM LEVEL_04',
    );
    if (list.isNotEmpty) {
      // 如果已经含有数据，则清空数据表
      await db.delete(TABLE_NAME);
      // 重置自增 ID：
      await db
          .rawDelete("DELETE FROM sqlite_sequence WHERE name=?", [TABLE_NAME]);
    }

    final data = await rootBundle
        .loadString('assets/data/' + TABLE_NAME + '.csv'); // 检查数据表是否已经含有数据
    // 读取csv，以\t为行分界：
    List<String> lines = data.trim().split('\n'); // trim是为了删掉最后的空行
    // print('Number of lines: ${lines.length}');
    for (int i = 1; i < lines.length; i++) {
      // 跳过header
      var row = lines[i].split(',');
      // 很有用的debug   print('row --> ' + row.toString());
      Map<String, dynamic> rowMap = {
        // FOOD_ID 会被自动添加
        'FOOD_NAME': row[0],
        'YEAR_15': row[1], // 使用反引号包裹数字列名
        'YEAR_20': row[2],
        'YEAR_25': row[3],
        'YEAR_30': row[4]
      };
      await db.insert(TABLE_NAME, rowMap);
    }
  }

  // Future<List<String>> queryFoodNamesByYear(String col) async {
  //   Database db = await database;
  //   List<Map> results = await db.query(TABLE_NAME,
  //       columns: [col], where: '$col > ?', whereArgs: [0] // 只获取数量大于0的食物
  //       );

  //   return List.generate(results.length, (i) {
  //     return results[i]['FOOD_NAME'].toString();
  //   });
  // }

  Future<List<Map>> queryAll() async {
    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'));
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      """
      SELECT * FROM LEVEL_04
    """,
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> queryFoodCountAtYear(String col) async {
    // 该函数返回的是LEVEL_04.csv中的FOOD_NAME + YEAR_？两列
    // 用于告诉程序 在给定的游戏时段内 总共应该生成多少种食物

    // 验证列名是否有效
    if (!['YEAR_15', 'YEAR_20', 'YEAR_25', 'YEAR_30'].contains(col)) {
      throw ArgumentError('Invalid column name');
    }

    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, TABLE_NAME + '.db'));

    // 直接将列名插入到 SQL 语句中
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
      SELECT FOOD_NAME, $col FROM LEVEL_04
    """);
    return maps;
    //////////////////  返回的数据格式：//////////////////////
    // [                                                 //
    //   {'FOOD_NAME': 'watermelon', 'YEAR_20': '5'},    //
    //   {'FOOD_NAME': 'apple', 'YEAR_20': '3'},         //
    //   {'FOOD_NAME': 'banana', 'YEAR_20': '2'}         //
    // ]                                                 //
    //////////////////  返回的数据格式：//////////////////////
  }
}
