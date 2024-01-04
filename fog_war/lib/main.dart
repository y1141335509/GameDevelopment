// import 'package:flame/flame.dart';
// import 'package:flame/game.dart';
// import 'package:flame_tiled/flame_tiled.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:fog_war/pixel_adventure.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized(); // 确保游戏有被正确初始化
//   Flame.device.fullScreen(); // 设置为全屏游戏
//   Flame.device.setLandscape(); // 设置为横屏游戏

//   runApp(GameWidget(
//     game: TileTutorialGame(),
//   ));
// }

// class TileTutorialGame extends FlameGame {
//   Future<void> onLoad() async {
//     await super.onLoad();
//     final homeMap =
//         await TiledComponent.load('level_01.tmx', Vector2.all(16.0));
//     add(homeMap);
//   }
// }

//////////////////////////////////////////////////////////////////
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

void main() {
  runApp(GameWidget(game: SpaceShooterGame())); // 游戏入口点
}

// 定义Player类
class Player extends SpriteComponent {
  void move(Vector2 delta) {
    position.add(delta);
  }
}

// 创建游戏
class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player; // player

  // 设置游戏背景色：
  @override
  Color backgroundColor() => const Color.fromARGB(134, 50, 167, 209);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 创建player及其形象
    final playerSprite = await loadSprite('sprite-basic.png');

    player = Player()
      ..sprite = playerSprite
      ..x = size.x / 2
      ..y = size.y / 2
      ..width = 50
      ..height = 100
      ..anchor = Anchor.center;
    add(player);
  }

  // 使用该方法接受player pan的输入信息
  @override
  void onPanUpdate(DragUpdateInfo info) {
    // 根据Player所接收到的input，来更新player的位置：
    player.move(info.delta.global);
  }
}
