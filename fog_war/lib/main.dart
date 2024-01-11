import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Game;
import 'package:fog_war/src/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(GameWidget(game: MainRouterGame()));
}
