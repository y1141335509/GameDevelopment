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
        PRIMARY KEY('ID' AUTOINCREMENT)
      );
    """);
  }

  Future<int> create(
      {required double water,
      required double energy,
      required double protein}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''INSERT INTO $tableName (water, energy, protein) VALUES (?, ?, ?)''',
      [water, energy, protein],
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

  Future<int> update(
      {required int id, double? water, double? energy, double? protein}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (water != null) 'water': water,
        if (energy != null) 'energy': energy,
        if (protein != null) 'protein': protein,
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
}
