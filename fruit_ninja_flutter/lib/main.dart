import 'package:flutter/material.dart';
import 'initial_screen.dart';
import 'game_main_menu.dart';
import 'package:flutter/services.dart';

void main() {
  // runApp(InitialScreen());
  runApp(MaterialApp(
    home: GameMenuScreen(),
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
      title: 'Fruit Ninja clone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitialScreen(),
    );
  }
}
