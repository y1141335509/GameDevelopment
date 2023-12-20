import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBInitializer {
  static final DBInitializer _instance = DBInitializer._internal();
  static Database? _database;

  ////////////////////////////////////////////
  ///                                      ///
  ///                                      ///
  // 私有的命名构造函数
  DBInitializer._internal();

  // 工厂构造函数
  factory DBInitializer() {
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

    return openDatabase(path.join(dbPath, 'food_nutrition.db'),
        onCreate: (database, version) async {
      // 然后创建food_nutrition表：
      await database.execute("""
        CREATE TABLE food_nutrition
        ('FOOD_ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        'NAME' VARCHAR(100) NOT NULL,
        'UNIT' VARCHAR(30),
        'WATER' DOUBLE NOT NULL,
        'ENERGY' DOUBLE NOT NULL,
        'PROTEIN' DOUBLE NOT NULL,
        'FAT' DOUBLE NOT NULL,
        'CARB' DOUBLE NOT NULL,
        'FIBER' DOUBLE NOT NULL,
        'SUGAR' DOUBLE NOT NULL,
        'CALCIUM' DOUBLE NOT NULL,
        'IRON' DOUBLE NOT NULL,
        'MAGNESIUM' DOUBLE NOT NULL,
        'PHOSPHORUS' DOUBLE NOT NULL,
        'POTASSIUM' DOUBLE NOT NULL,
        'SODIUM' DOUBLE NOT NULL,
        'ZINC' DOUBLE NOT NULL,
        'COPPER' DOUBLE NOT NULL,
        'MANGANESE' DOUBLE NOT NULL,
        'SELENIUM' DOUBLE NOT NULL,
        'VC' DOUBLE NOT NULL,
        'VB' DOUBLE NOT NULL,
        'VA' DOUBLE NOT NULL,
        'VD' DOUBLE NOT NULL,
        'VK' DOUBLE NOT NULL,
        'CAFFEINE' DOUBLE NOT NULL,
        'ALCOHOL' DOUBLE NOT NULL
        )""");
    }, version: 1);
  }

  static Future<void> importCSVToSQLite(Database db) async {
    // 检查数据表是否已经含有数据
    List<Map> list = await db.rawQuery('SELECT * FROM food_nutrition');
    if (list.isNotEmpty) {
      // 如果已经含有数据，则清空数据表
      await db.delete('food_nutrition');
      // 重置自增 ID：
      await db
          .rawDelete("DELETE FROM sqlite_sequence WHERE name='food_nutrition'");
    }

    final data = await rootBundle.loadString('assets/data/food_nutrition.csv');

    // second way to read csv:
    List<String> lines = data.split('\n');
    print('Number of lines: ${lines.length}');

    for (int i = 1; i < lines.length; i++) {
      // SKIP csv HEADER
      var row = lines[i].split(',');
      Map<String, dynamic> rowMap = {
        // FOOD_ID 会被自动添加
        'NAME': row[0],
        'UNIT': row[1],
        'WATER': row[2],
        'ENERGY': row[3],
        'PROTEIN': row[4],
        'FAT': row[5],
        'CARB': row[6],
        'FIBER': row[7],
        'SUGAR': row[8],
        'CALCIUM': row[9],
        'IRON': row[10],
        'MAGNESIUM': row[11],
        'PHOSPHORUS': row[12],
        'POTASSIUM': row[13],
        'SODIUM': row[14],
        'ZINC': row[15],
        'COPPER': row[16],
        'MANGANESE': row[17],
        'SELENIUM': row[18],
        'VC': row[19],
        'VB': row[20],
        'VA': row[21],
        'VD': row[22],
        'VK': row[23],
        'CAFFEINE': row[24],
        'ALCOHOL': row[25]
      };
      await db.insert('food_nutrition', rowMap);
    }
  }

  Future<List<String>> queryAllFoodNames() async {
    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'food_nutrition.db'));

    final List<Map<String, dynamic>> maps =
        await db.query('food_nutrition', columns: ['NAME']);
    return List.generate(maps.length, (i) {
      return maps[i]['NAME'];
    });
  }

  Future<List<Map>> queryFoodNutritions() async {
    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'food_nutrition.db'));
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
        SELECT * FROM food_nutrition
        WHERE NAME NOT IN ('lower', 'upper')
      """);
    return maps;
  }

  Future<List<Map>> queryFoodNutritionByName(String name) async {
    String dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'food_nutrition.db'));
    final List<Map<String, dynamic>> maps = await db.rawQuery("""
        SELECT * FROM food_nutrition
        WHERE NAME = ?
      """, [name]);
    return maps;
  }
  ///                                      ///
  ///                                      ///
  ////////////////////////////////////////////
}
