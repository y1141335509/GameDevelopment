import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'initial_screen.dart';
import 'game_main_menu.dart';
import './db_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database db = await DBInitializer.initializeDB(); // 数据库初始化函数
  await DBInitializer.importCSVToSQLite(db); // 导入CSV数据到SQLite
  // runApp(InitialScreen());
  runApp(MaterialApp(
    home: GameMenuScreen(),   // from the `game_main_menu.dart`
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // set landscape orientation:
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // this is where your app starts
    return MaterialApp(
      title: 'Food vs Death',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitialScreen(),    // from the `initial_screen.dart`
    );
  }
}



