import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:fog_war/src/components/rectangle_test.dart';
import 'package:fog_war/src/config/app_config.dart';
import 'package:fog_war/src/routes/game_over_page.dart';
import 'package:fog_war/src/routes/game_page.dart';
import 'package:fog_war/src/routes/home_page.dart';
import 'package:fog_war/src/routes/pause_game.dart';

class MainRouterGame extends FlameGame {
  late final RouterComponent router;
  late double maxVerticalVelocity;

  @override
  void onLoad() async {
    await super.onLoad();

    addAll([
      ParallaxComponent(
          parallax: Parallax(
              [await ParallaxLayer.load(ParallaxImageData('bg.png'))])),
      router = RouterComponent(initialRoute: 'home', routes: {
        'home': Route(HomePage.new),
        'game-page': Route(GamePage.new),
        'pause': PauseRoute(),
        'game-over': GameOverRoute(),
      })
    ]);
  }

  // @override
  // void onDragUpdate(DragUpdateEvent event) {
  //   // TODO
  //   super.onDragUpdate(event);

  //   // ignore: deprecated_member_use
  //   componentsAtPoint(event.canvasPosition).forEach((element) {
  //     if (element is RectangleTest) {
  //       // ignore: deprecated_member_use
  //       element.touchAtPoint(event.canvasPosition);
  //     }
  //   });
  // }

  @override
  void onGameResize(Vector2 size) {
    // TODO -> implement onGameResize
    super.onGameResize(size);
    getMaxVerticalVelocity(size);
  }

  void getMaxVerticalVelocity(Vector2 size) {
    maxVerticalVelocity = sqrt(2 *
        (AppConfig.gravity.abs() + AppConfig.acceleration.abs()) *
        (size.y - AppConfig.objSize * 2));
  }
}
