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
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

void main() {
  runApp(GameWidget(game: SpaceShooterGame())); // 游戏入口点
}

// 定义Player类
class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Player() : super(size: Vector2(100, 150), anchor: Anchor(-100, -100));

  // override onload() function and define basic pixel image for initial sprite
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = await game.loadSpriteAnimation(
        'sprite-basic.png',
        SpriteAnimationData.sequenced(
            amount: 4, stepTime: .2, textureSize: Vector2(32, 32)));
  }

  // movement
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

    // 创建player攻击动画：
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('sprite-attack-1.png'),
        ParallaxImageData('sprite-attack-2.png'),
        ParallaxImageData('sprite-attack-3.png'),
      ],
      baseVelocity: Vector2(0, -5),
      repeat: ImageRepeat.repeat,
      velocityMultiplierDelta: Vector2(0, 5),
    );
    add(parallax);  // 添加背景星空，让玩家感觉飞机在前进

    // 添加基础的player形象
    player = Player();
    add(player);
  }

  // 使用该方法接受player pan的输入信息
  @override
  void onPanUpdate(DragUpdateInfo info) {
    // 根据Player所接收到的input，来更新player的位置：
    player.move(info.delta.global);
  }
}
