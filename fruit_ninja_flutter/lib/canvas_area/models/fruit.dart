import 'dart:ui';

import 'gravitational_object.dart';

class Fruit extends GravitationalObject {
  Fruit({
    required this.width,
    required this.height,
    required super.position,
    required this.name,
    super.gravitySpeed = 0.0,
    super.additionalForce = const Offset(0, 0),
    super.rotation = 0.25,
  });

  final double width;
  final double height;
  final String name;

  bool isPointInside(Offset point) {
    if (point.dx < position.dx) {
      return false;
    }

    if (point.dx > position.dx + width) {
      return false;
    }

    if (point.dy < position.dy) {
      return false;
    }

    if (point.dy > position.dy + height) {
      return false;
    }

    return true;
  }

  Map<String, double> watermelon = {
    'water': 4130.0,
    'energy': 1360,
    'protein': 27.6,
    'fat': 6.78,
    'ash': 11.3,
    'carb': 341,
    'fiber': 18.1,
    'sugars': 280,
    'sucrose': 54.7,
    'glucose': 71.4,
    'calcium': 316,
    'iron': 10.8,
    'magnesium': 452,
    'phosphorus': 497,
    'potassium': 5060,
    'sodium': 45.2,
    'zinc': 4.52,
    'copper': 1.9,
    'manganese': 1.72,
    'selenium': 18.1,
    'VC': 366,
    'VB': 2.03,
    'VA': 1270,
    'VD': 0,
    'VK': 4.52,
    'caffeine': 0,
    'alcohol': 0,
  };

  Map<String, double> apple = {
    'water': 83.6,
    'energy': 65,
    'protein': .15,
    'fat': .16,
    'ash': .43,
    'carb': 15.6,
    'fiber': 2.1,
    'sugars': 13.3,
    'sucrose': 1.7,
    'glucose': 3.04,
    'calcium': 6,
    'iron': 0.02,
    'magnesium': 4.7,
    'phosphorus': 10,
    'potassium': 104,
    'sodium': 1,
    'zinc': 0.02,
    'copper': 0.033,
    'manganese': 0.033,
    'selenium': 0,
    'VC': 5.7,
    'VB': 0.045,
    'VA': 2,
    'VD': 0,
    'VK': 1,
    'caffeine': 0,
    'alcohol': 0,
  };

  Map<String, double> banana = {
    'water': 75.3,
    'energy': 98,
    'protein': .74,
    'fat': .29,
    'ash': .7,
    'carb': 23,
    'fiber': 1.7,
    'sugars': 15.8,
    'sucrose': 4.18,
    'glucose': 5.55,
    'calcium': 5,
    'iron': .4,
    'magnesium': 28,
    'phosphorus': 22,
    'potassium': 326,
    'sodium': 4,
    'zinc': .16,
    'copper': .101,
    'manganese': .258,
    'selenium': 2.5,
    'VC': 12.3,
    'VB': .209,
    'VA': 1,
    'VD': 0,
    'VK': .1,
    'caffeine': 0,
    'alcohol': 0,
  };




}
