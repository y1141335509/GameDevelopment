import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';



class Body {
  int id;
  double _water;
  double _energy;
  double _protein;
  double _fat;
  double _carb;
  double _fiber;
  double _sugar;
  double _calcium;
  double _iron;
  double _magnesium;
  double _phosphorus;
  double _potassium;
  double _sodium;
  double _zinc;
  double _copper;
  double _manganese;
  double _selenium;
  double _vc;
  double _vb;
  double _va;
  double _vd;
  double _vk;
  double _caffeine;
  double _alcohol;

  Body ({required this.id, required double water, required double energy, required double protein,
      required double fat, required double carb, required double fiber,
      required double sugar, required double calcium, required double iron,
      required double magnesium, required double phosphorus, required double potassium,
      required double sodium, required double zinc, required double copper,
      required double manganese, required double selenium, required double vc,
      required double vb, required double va, required double vd,
      required double vk, required double caffeine, required double alcohol})
      : _water = water, _energy = energy, _protein = protein,
        _fat = fat, _carb = carb, _fiber = fiber,
        _sugar = sugar, _calcium = calcium, _iron = iron,
        _magnesium = magnesium, _phosphorus = phosphorus, _potassium = potassium,
        _sodium = sodium, _zinc = zinc, _copper = copper,
        _manganese = manganese, _selenium = selenium, _vc = vc,
        _vb = vb, _va = va, _vd = vd,
        _vk = vk, _caffeine = caffeine, _alcohol = alcohol;

  set water(double value) => _water = value;
  set energy(double value) => _energy = value;
  set protein(double value) => _protein = value;
  set fat(double value) => _fat = value; 
  set carb(double value) => _carb = value; 
  set fiber(double value) => _fiber = value;
  set sugar(double value) => _sugar = value; 
  set calcium(double value) => _calcium = value; 
  set iron(double value) => _iron = value;
  set magnesium(double value) => _magnesium = value; 
  set phosphorus(double value) => _phosphorus = value; 
  set potassium(double value) => _potassium = value;
  set sodium(double value) => _sodium = value; 
  set zinc(double value) => _zinc = value; 
  set copper(double value) => _copper = value;
  set manganese(double value) => _manganese = value; 
  set selenium(double value) => _selenium = value; 
  set vc(double value) => _vc = value;
  set vb(double value) => _vb = value; 
  set va(double value) => _va = value; 
  set vd(double value) => _vd = value;
  set vk(double value) => _vk = value; 
  set caffeine(double value) => _caffeine = value; 
  set alcohol(double value) => _alcohol;

  // Optionally, you can define getters if needed
  double get water => _water;
  double get energy => _energy;
  double get protein => _protein;
  double get fat => _fat; 
  double get carb => _carb; 
  double get fiber => _fiber;
  double get sugar => _sugar; 
  double get calcium => _calcium; 
  double get iron => _iron;
  double get magnesium => _magnesium; 
  double get phosphorus => _phosphorus; 
  double get potassium => _potassium;
  double get sodium => _sodium; 
  double get zinc => _zinc; 
  double get copper => _copper;
  double get manganese => _manganese; 
  double get selenium => _selenium; 
  double get vc => _vc;
  double get vb => _vb; 
  double get va => _va; 
  double get vd => _vd;
  double get vk => _vk; 
  double get caffeine => _caffeine; 
  double get alcohol => _alcohol;

  factory Body.fromSqfliteDatabase(Map<String, dynamic> map) => Body(
      id: map['ID']?.toInt() ?? 0,
      water: map['water'] ?? 0,
      energy: map['energy'] ?? 0,
      protein: map['protein'] ?? 0,
      fat: map['fat'] ?? 0,  
      carb: map['carb'] ?? 0,  
      fiber: map['fiber'] ?? 0, 
      sugar: map['sugar'] ?? 0,  
      calcium: map['calcium'] ?? 0,  
      iron: map['iron'] ?? 0, 
      magnesium: map['magnesium'] ?? 0,  
      phosphorus: map['phosphorus'] ?? 0,  
      potassium: map['potassium'] ?? 0, 
      sodium: map['sodium'] ?? 0,  
      zinc: map['zinc'] ?? 0,  
      copper: map['copper'] ?? 0, 
      manganese: map['manganese'] ?? 0,  
      selenium: map['selenium'] ?? 0,  
      vc: map['vc'] ?? 0, 
      vb: map['vb'] ?? 0,  
      va: map['va'] ?? 0,  
      vd: map['vd'] ?? 0, 
      vk: map['vk'] ?? 0,  
      caffeine: map['caffeine'] ?? 0,  
      alcohol: map['alcohol'] ?? 0, 
    );
}









// Map<String, double> watermelon = {
//   'water': 4130.0,
//   'energy': 1360,
//   'protein': 27.6,
//   'fat': 6.78,
//   'carb': 341,
//   'fiber': 18.1,
//   'sugars': 280,
//   'calcium': 316,
//   'iron': 10.8,
//   'magnesium': 452,
//   'phosphorus': 497,
//   'potassium': 5060,
//   'sodium': 45.2,
//   'zinc': 4.52,
//   'copper': 1.9,
//   'manganese': 1.72,
//   'selenium': 18.1,
//   'VC': 366,
//   'VB': 2.03,
//   'VA': 1270,
//   'VD': 0,
//   'VK': 4.52,
//   'caffeine': 0,
//   'alcohol': 0,
// };

// Map<String, double> apple = {
//   'water': 83.6,
//   'energy': 65,
//   'protein': .15,
//   'fat': .16,
//   'ash': .43,
//   'carb': 15.6,
//   'fiber': 2.1,
//   'sugars': 13.3,
//   'sucrose': 1.7,
//   'glucose': 3.04,
//   'calcium': 6,
//   'iron': 0.02,
//   'magnesium': 4.7,
//   'phosphorus': 10,
//   'potassium': 104,
//   'sodium': 1,
//   'zinc': 0.02,
//   'copper': 0.033,
//   'manganese': 0.033,
//   'selenium': 0,
//   'VC': 5.7,
//   'VB': 0.045,
//   'VA': 2,
//   'VD': 0,
//   'VK': 1,
//   'caffeine': 0,
//   'alcohol': 0,
// };

// Map<String, double> banana = {
//   'water': 75.3,
//   'energy': 98,
//   'protein': .74,
//   'fat': .29,
//   'ash': .7,
//   'carb': 23,
//   'fiber': 1.7,
//   'sugars': 15.8,
//   'sucrose': 4.18,
//   'glucose': 5.55,
//   'calcium': 5,
//   'iron': .4,
//   'magnesium': 28,
//   'phosphorus': 22,
//   'potassium': 326,
//   'sodium': 4,
//   'zinc': .16,
//   'copper': .101,
//   'manganese': .258,
//   'selenium': 2.5,
//   'VC': 12.3,
//   'VB': .209,
//   'VA': 1,
//   'VD': 0,
//   'VK': .1,
//   'caffeine': 0,
//   'alcohol': 0,
// };
