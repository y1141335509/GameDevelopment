import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fog_war/pixel_adventure.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 确保游戏有被正确初始化
  Flame.device.fullScreen(); // 设置为全屏游戏
  Flame.device.setLandscape(); // 设置为横屏游戏

  runApp(GameWidget(
    game: TileTutorialGame(),
  ));
}



class TileTutorialGame extends FlameGame {
  Future<void> onLoad() async {
    print('loading assets. ..');

    await super.onLoad();
    final homeMap =
        await TiledComponent.load('level_01.tmx', Vector2.all(16.0));
    add(homeMap);
  }
}
