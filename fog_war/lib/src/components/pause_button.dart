import 'dart:ui';

import 'package:flame/components.dart';
import 'package:fog_war/src/game.dart';
import 'package:fog_war/src/components/simple_button.dart';


class PauseButton extends SimpleButton with HasGameReference<MainRouterGame> {
  PauseButton({VoidCallback? onPressed})
      : super(
          Path()
            ..moveTo(14, 10)
            ..lineTo(14, 30)
            ..moveTo(26, 10)
            ..lineTo(26, 30),
          position: Vector2(60, 10),
        ) {
    super.action = onPressed ?? () => game.router.pushNamed('pause');
  }
}
