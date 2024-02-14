import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';

class Utils {
  Utils._();

  static int getAngleOfTouchPoint(
      {required Vector2 center,
      required double initAngle,
      required Vector2 touch}) {
    final touchPoint = touch - center;

    double angle = atan2(touchPoint.y, touchPoint.x);

    angle -= initAngle;
    angle %= 2 * pi;

    return radiansToDegrees(angle).toInt();
  }

  static double radiansToDegrees(double angle) => angle * 180 / pi;
}
