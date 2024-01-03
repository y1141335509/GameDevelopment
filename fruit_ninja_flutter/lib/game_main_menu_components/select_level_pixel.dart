import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './levels/level_00.dart';
import './levels/level_01.dart';
import './levels/level_02.dart';
import './levels/level_03.dart';




class LevelSelectionScreen extends FlameGame {
  Future<void> onLoad() async {
    await super.onLoad();
    final worldMap =
        await TiledComponent.load('world_map.tmx', Vector2.all(16.0));
    add(worldMap);
  }
}











