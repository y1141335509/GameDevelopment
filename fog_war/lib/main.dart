import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fog_war/pixel_adventure.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();    // 确保游戏有被正确初始化
  Flame.device.fullScreen();      // 设置为全屏游戏
  Flame.device.setLandscape();    // 设置为横屏游戏


  PixelAdventure game = PixelAdventure();

  // 默认使用debug 模式，否则直接运行游戏。
  runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
}
