// import './levels/level_00.dart';
// import './levels/level_01.dart';
// import './levels/level_02.dart';
// import './levels/level_03.dart';

import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';

class LevelSelectionScreen extends FlameGame
    with ScrollDetector, ScaleDetector {
  static const String description = '''
    On web: use scroll to zoom in and out.\n
    On mobile: use scale gesture to zoom in and out.
    Reference:
    1. https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/zoom_example.dart
    2. https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/camera_and_viewport.dart
  ''';

  // 添加两个新的属性来限制镜头的移动范围：
  final Vector2 mapSize; // 地图尺寸
  final Vector2 worldBoundaries; // 地图边界

  LevelSelectionScreen({
    required Vector2 viewportResolution,

    // 添加下面两个新的属性来限制镜头的移动范围：
    required this.mapSize,
    required this.worldBoundaries,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            width: viewportResolution.x,
            height: viewportResolution.y,
          ),
        );

  late final TiledComponent worldMap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    worldMap = await TiledComponent.load('world_map.tmx', Vector2.all(4.0));

    world.add(worldMap..anchor = Anchor.center);
  }

  void clampZoom() {
    // zoom.clamp函数就是用来设置地图能够被缩放的最大上下限的.
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(1, 4.0);
  }

  // 每次所能够缩放的单位大小
  static const zoomPerScrollUnit = 0.04;

  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom +=
        info.scrollDelta.global.y.sign * zoomPerScrollUnit;

    clampZoom();
  }

  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.viewfinder.zoom = startZoom * currentScale.y;
      clampZoom();
    } else {
      final delta = info.delta.global;
      // 限制摄像机的移动范围
      Vector2 newPos = camera.viewfinder.position - delta;
      newPos.x = newPos.x.clamp(-worldBoundaries.x, worldBoundaries.x);
      newPos.y = newPos.y.clamp(-worldBoundaries.y, worldBoundaries.y);
      print('摄像机边界： ' + newPos.x.toString() + ' ' + newPos.y.toString());
      camera.viewfinder.position = newPos;
    }
  }
}
