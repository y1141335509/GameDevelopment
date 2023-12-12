import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import './database_service.dart';
import '../models/body.dart';

class BodyDB {
  final tableName = 'body';

  Future<void> createTable(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $tableName (
        'ID' INTEGER NOT NULL,
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
          (water, energy, protein, fat, carb, fiber, sugar, calcium, iron, magnesium, phosphorus, potassium, sodium, zinc, copper, manganese, selenium, vc, vb, va, vd, vk, caffeine, alcohol) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
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

  Future<List<Map<String, dynamic>>> fetchFruitNutrition() async {
    final database = await DatabaseService().database;
    final List<Map<String, dynamic>> results =
        await database.query('FruitNutrition');
    return results;
  }
}
