class Player {
  int id;
  double water;
  double energy;
  double protein;
  double fat;
  double carb;
  double fiber;
  double sugar;
  double calcium;
  double iron;
  double magnesium;
  double phosphorus;
  double potassium;
  double sodium;
  double zinc;
  double copper;
  double manganese;
  double selenium;
  double vc;
  double vb;
  double va;
  double vd;
  double vk;
  double caffeine;
  double alcohol;

  Player({
    required this.id,
    this.water = 0.0,
    this.energy = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
    this.carb = 0.0,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.calcium = 0.0,
    this.iron = 0.0,
    this.magnesium = 0.0,
    this.phosphorus = 0.0,
    this.potassium = 0.0,
    this.sodium = 0.0,
    this.zinc = 0.0,
    this.copper = 0.0,
    this.manganese = 0.0,
    this.selenium = 0.0,
    this.vc = 0.0,
    this.vb = 0.0,
    this.va = 0.0,
    this.vd = 0.0,
    this.vk = 0.0,
    this.caffeine = 0.0,
    this.alcohol = 0.0,
  });

  factory Player.fromSqfliteDatabase(Map<String, dynamic> map) => Player(
    id: map['ID']?.toInt() ?? 0,
    water: map['water'] ?? 0.0,
    energy: map['energy'] ?? 0.0,
    protein: map['protein'] ?? 0.0,
    fat: map['fat'] ?? 0.0,
    carb: map['carb'] ?? 0.0,
    fiber: map['fiber'] ?? 0.0,
    sugar: map['sugar'] ?? 0.0,
    calcium: map['calcium'] ?? 0.0,
    iron: map['iron'] ?? 0.0,
    magnesium: map['magnesium'] ?? 0.0,
    phosphorus: map['phosphorus'] ?? 0.0,
    potassium: map['potassium'] ?? 0.0,
    sodium: map['sodium'] ?? 0.0,
    zinc: map['zinc'] ?? 0.0,
    copper: map['copper'] ?? 0.0,
    manganese: map['manganese'] ?? 0.0,
    selenium: map['selenium'] ?? 0.0,
    vc: map['vc'] ?? 0.0,
    vb: map['vb'] ?? 0.0,
    va: map['va'] ?? 0.0,
    vd: map['vd'] ?? 0.0,
    vk: map['vk'] ?? 0.0,
    caffeine: map['caffeine'] ?? 0.0,
    alcohol: map['alcohol'] ?? 0.0,
  );
}







