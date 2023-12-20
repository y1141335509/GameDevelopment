import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import './database_service.dart';
import '../game_main_menu_components/levels/models/body.dart';

class FoodNutrition {
  final tableName = 'FoodNutrition';

  Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        'FOOD_ID' INTEGER NOT NULL,
        'NAME' VARCHAR(100) NOT NULL,
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
        'ALCOHOL' DOUBLE NOT NULL,
        PRIMARY KEY('ID' AUTOINCREMENT)
      );
    """);
  }

  Future<int> create({
    required String name,
    required double water,
    required double energy,
    required double protein,
    required double fat,
    required double carb,
    required double fiber,
    required double sugar,
    required double calcium,
    required double iron,
    required double magnesium,
    required double phosphorus,
    required double potassium,
    required double sodium,
    required double zinc,
    required double copper,
    required double manganese,
    required double selenium,
    required double vc,
    required double vb,
    required double va,
    required double vd,
    required double vk,
    required double caffeine,
    required double alcohol,
  }) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName 
          (name, water, energy, protein, fat, carb, fiber, sugar, calcium, iron, magnesium, phosphorus, potassium, sodium, zinc, copper, manganese, selenium, vc, vb, va, vd, vk, caffeine, alcohol) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        name,
        water,
        energy,
        protein,
        fat,
        carb,
        fiber,
        sugar,
        calcium,
        iron,
        magnesium,
        phosphorus,
        potassium,
        sodium,
        zinc,
        copper,
        manganese,
        selenium,
        vc,
        vb,
        va,
        vd,
        vk,
        caffeine,
        alcohol
      ],
    );
  }

  Future<List<Body>> fetchAll() async {
    final database = await DatabaseService().database;
    final body = await database.rawQuery('''SELECT * FROM $tableName;''');
    return body.map((b) => Body.fromSqfliteDatabase(b)).toList();
  }

  Future<Body> fetchById(int id) async {
    final database = await DatabaseService().database;
    final body = await database.rawQuery("""
      SELECT * FROM $tableName WHERE ID = ?""", [id]);
    return Body.fromSqfliteDatabase(body.first);
  }

  Future<int> update({
    required int id,
    String? name,
    double? water,
    double? energy,
    double? protein,
    double? fat,
    double? carb,
    double? fiber,
    double? sugar,
    double? calcium,
    double? iron,
    double? magnesium,
    double? phosphorus,
    double? potassium,
    double? sodium,
    double? zinc,
    double? copper,
    double? manganese,
    double? selenium,
    double? vc,
    double? vb,
    double? va,
    double? vd,
    double? vk,
    double? caffeine,
    double? alcohol,
  }) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (name != null) 'name': name,
        if (water != null) 'water': water,
        if (energy != null) 'energy': energy,
        if (protein != null) 'protein': protein,
        if (fat != null) 'fat': fat,
        if (carb != null) 'carb': carb,
        if (fiber != null) 'fiber': fiber,
        if (sugar != null) 'sugar': sugar,
        if (calcium != null) 'calcium': calcium,
        if (iron != null) 'iron': iron,
        if (magnesium != null) 'magnesium': magnesium,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (sodium != null) 'sodium': sodium,
        if (zinc != null) 'zinc': zinc,
        if (copper != null) 'copper': copper,
        if (manganese != null) 'manganese': manganese,
        if (selenium != null) 'selenium': selenium,
        if (vc != null) 'vc': vc,
        if (vb != null) 'vb': vb,
        if (va != null) 'va': va,
        if (vd != null) 'vd': vd,
        if (vk != null) 'vk': vk,
        if (caffeine != null) 'caffeine': caffeine,
        if (alcohol != null) 'alcohol': alcohol,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete("""DELETE FROM $tableName WHERE id = ?""", [id]);
  }

  Future<List<Map<String, dynamic>>> fetchFoodNutrition() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> results =
        await database.query(tableName);
    return results;
  }

  Future<Map<String, Map<String, double>>> getFoodNutritionalValues() async {
    var dbResults = await FoodNutrition().fetchFoodNutrition();
    Map<String, Map<String, double>> foodNutritionalValues = {};

    for (var row in dbResults) {
      String name = row['name'];
      double water = row['water'];
      double energy = row['energy'];
      double protein = row['protein'];
      double fat = row['fat'];
      double carb = row['carb'];
      double fiber = row['fiber'];
      double sugar = row['sugar'];
      double calcium = row['calcium'];
      double iron = row['iron'];
      double magnesium = row['magnesium'];
      double phosphorus = row['phosphorus'];
      double potassium = row['potassium'];
      double sodium = row['sodium'];
      double zinc = row['zinc'];
      double copper = row['copper'];
      double manganese = row['manganese'];
      double selenium = row['selenium'];
      double vc = row['vc'];
      double vb = row['vb'];
      double va = row['va'];
      double vd = row['cd'];
      double vk = row['vk'];
      double caffeine = row['caffeine'];
      double alcohol = row['alcohol'];

      foodNutritionalValues[name] = {
        'water': water,
        'energy': energy,
        'protein': protein,
        'fat': fat, 
        'carb': carb, 
        'fiber': fiber, 
        'sugar': sugar, 
        'calcium': calcium, 
        'iron': iron, 
        'magnesium': magnesium, 
        'phosphorus': phosphorus, 
        'potassium': potassium, 
        'sodium': sodium, 
        'zinc': zinc, 
        'copper': copper, 
        'manganese': manganese, 
        'selenium': selenium, 
        'vc': vc, 
        'vb': vb, 
        'va': va, 
        'vd': vd, 
        'vk': vk, 
        'caffeine': caffeine, 
        'alcohol': alcohol, 
      };
    }

    return foodNutritionalValues;
  }


  Future<Map<String, Map<String, double>>> loadCsvData() async {
    final rawCsv = await rootBundle.loadString('assets/food_nutrition.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawCsv);
    return _convertToMap(listData);
  }

  Map<String, Map<String, double>> _convertToMap(List<List<dynamic>> csvData) {
    Map<String, Map<String, double>> foodNutritionalValues = {};

    for (var i = 1; i < csvData.length; i++) { // Skip header row
      var row = csvData[i];
      String name = row[1]; // Assuming name is in the second column
      // ... extract other nutritional values ...

      foodNutritionalValues[name] = {
        'water': row[2].toDouble(),
        'energy': row[3].toDouble(),
        'protein': row[4].toDouble(),
        // ... and so on for other nutrients ...
      };
    }

    return foodNutritionalValues;
  }
}
