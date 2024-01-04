import 'dart:ui';

import 'package:flame/game.dart';
import './levels/level.dart';
import 'dart:async';
import 'package:flame/components.dart';

class PixelAdventure extends FlameGame {

  @override
  // Color backgroundColor() => const Color.fromRGBO(33, 31, 48, 1);
  final world = Level();
  late final CameraComponent cam;

  @override
  FutureOr<void> onLoad() {
    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    return super.onLoad();
  }
}
