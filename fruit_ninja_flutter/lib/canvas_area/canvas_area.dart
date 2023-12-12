import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vege_vs_zombie/canvas_area/database/body_db.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'models/fruit.dart';
import './models/body.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'slice_painter.dart';

List<String> fruitNames = ['melon', 'apple', 'banana', 'avocado'];

// fruitsCut defines the number of each fruit type is cut after game play.
Map<String, int> foodSpawnCount = {
  'melon': 0,
  'apple': 0,
  'banana': 0,
  'avocado': 0
};

Map<String, Map<String, double>> foodNutritions = {
  "melon": {
    "water": 4130.0,
    "energy": 1360.0,
    "protein": 27.6,
    "fat": 6.78,
    "carb": 341,
    "fiber": 18.1,
    "sugar": 280,
    "calcium": 316,
    "iron": 10.8,
    "magnesium": 452,
    "phosphorus": 497,
    "potassium": 5060,
    "sodium": 45.2,
    "zinc": 4.52,
    "copper": 1.9,
    "manganese": 1.72,
    "selenium": 18.1,
    "vc": 366,
    "vb": 2.03,
    "va": 1270,
    "vd": 0,
    "vk": 4.52,
    "caffeine": 0,
    "alcohol": 0
  },
  "apple": {
    "water": 83.6,
    "energy": 65,
    "protein": 0.15,
    "fat": 0.16,
    "carb": 15.6,
    "fiber": 2.1,
    "sugar": 13.3,
    "calcium": 6,
    "iron": 0.02,
    "magnesium": 4.7,
    "phosphorus": 10,
    "potassium": 104,
    "sodium": 1,
    "zinc": 0.02,
    "copper": 0.033,
    "manganese": 0.033,
    "selenium": 0,
    "vc": 5.7,
    "vb": 0.045,
    "va": 2,
    "vd": 0,
    "vk": 1,
    "caffeine": 0,
    "alcohol": 0
  },
  "banana": {
    "water": 75.3,
    "energy": 98,
    "protein": 0.74,
    "fat": 0.29,
    "carb": 23,
    "fiber": 1.7,
    "sugar": 15.8,
    "calcium": 5,
    "iron": 0.4,
    "magnesium": 28,
    "phosphorus": 22,
    "potassium": 326,
    "sodium": 4,
    "zinc": 0.16,
    "copper": 0.101,
    "manganese": 0.258,
    "selenium": 2.5,
    "vc": 12.3,
    "vb": 0.209,
    "va": 1,
    "vd": 0,
    "vk": 0.1,
    "caffeine": 0,
    "alcohol": 0
  },
  "avocado": {
    "water": 73.2,
    "energy": 160,
    "protein": 670,
    "fat": 14.7,
    "carb": 8.53,
    "fiber": 6.7,
    "sugar": 0.66,
    "calcium": 12,
    "iron": 0.55,
    "magnesium": 29,
    "phosphorus": 52,
    "potassium": 485,
    "sodium": 7,
    "zinc": 0.64,
    "copper": 0.19,
    "manganese": 0.142,
    "selenium": 0.4,
    "vc": 10,
    "vb": 0.257,
    "va": 7,
    "vd": 0,
    "vk": 21,
    "caffeine": 0,
    "alcohol": 0
  }
};

late Body player; // Instance to hold player's state

// max and min threshold for each fruit
Map<int, List> fruitMinMax = {
  20: [3, 10],
  40: [8, 20],
  60: [12, 25],
  80: [15, 30],
  100: [18, 33],
  120: [20, 35],
};

class CanvasArea extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CanvasAreaState();
  }
}

class _CanvasAreaState extends State<CanvasArea> with TickerProviderStateMixin {
  int _score = 0;
  TouchSlice? _touchSlice;
  final List<Fruit> _fruits = <Fruit>[];
  final List<FruitPart> _fruitParts = <FruitPart>[];
  late AnimationController _countdownController;
  bool _isGamePaused = false;

  // 2023/12/6 - try new mechanism:
  int _melonsCut = 0; // number of melons cut
  int _bananaCut = 0;
  int _appleCut = 0;
  int _avocadoCut = 0;

  // Initial maximum values
  double maxWater = 100000;
  double maxEnergy = 48000;
  double maxProtein = 2400;
  double maxFat = 16800;
  double maxCarb = 6000;
  double maxFiber = 1400;
  double maxSugar = 720;
  double maxCalcium = 50000;
  double maxIron = 900;
  double maxMagnesium = 7000;
  double maxPhosphorus = 80000;
  double maxPotassium = 94000;
  double maxSodium = 46000;
  double maxZinc = 800;
  double maxCopper = 200;
  double maxManganese = 220;
  double maxSelenium = 8000;
  double maxVc = 40000;
  double maxVb = 2000;
  double maxVa = 60000;
  double maxVd = 2000;
  double maxVk = 2400;
  double maxCaffeine = 8000;
  double maxAlcohol = 600000;

// Initial minimium values
  double minWater = 10000;
  double minEnergy = 24000;
  double minProtein = 960;
  double minFat = 4800;
  double minCarb = 2600;
  double minFiber = 500;
  double minSugar = 40;
  double minCalcium = 20000;
  double minIron = 160;
  double minMagnesium = 6400;
  double minPhosphorus = 14000;
  double minPotassium = 70000;
  double minSodium = 10000;
  double minZinc = 160;
  double minCopper = 18;
  double minManganese = 36;
  double minSelenium = 1100;
  double minVc = 1500;
  double minVb = 20;
  double minVa = 14000;
  double minVd = 300;
  double minVk = 1500;
  double minCaffeine = 20;
  double minAlcohol = 20;

  // Define the increase percentages for each time interval
  Map<int, double> increasePercentages = {
    20: 0.0, // 0% increase
    40: 1.0, // 100% increase
    60: 1.0, // 100% increase
    80: 0.8, // 80% increase
    100: 0.6, // 60% increase
    120: 0.4, // 40% increase
  };

  Set<int> checkedTimePoints = {}; // Tracks which time points have been checked

  @override
  void initState() {
    super.initState();

    // Initialize the countdown controller
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 120),
    )..addListener(() {
        setState(() {});
      });

    // Add status listener
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _endGame("Time's up!");
      }
    });

    // Start the countdown
    _countdownController.reverse(from: 1.0);

    // Initialize the player with default nutritional values
    player = Body(
        id: 0, // If id is not relevant at the moment, you can set it to 0 or any default value
        water: 50000.0, // Default water value
        energy: 2500.0, // Default energy value
        protein: 25.0, // Default protein value
        fat: 6.78,
        carb: 341,
        fiber: 18.1,
        sugar: 280,
        calcium: 316,
        iron: 10.8,
        magnesium: 452,
        phosphorus: 497,
        potassium: 5060,
        sodium: 45.2,
        zinc: 4.52,
        copper: 1.9,
        manganese: 1.72,
        selenium: 18.1,
        vc: 366,
        vb: 2.03,
        va: 1270,
        vd: 0,
        vk: 4.52,
        caffeine: 0,
        alcohol: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnRandomFruit();
    });

    _tick();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  String get countdownText {
    Duration duration =
        _countdownController.duration! * _countdownController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

////////////////////////////////////

  void _spawnRandomFruit() {
    final random = Random();
    String name = fruitNames[random.nextInt(fruitNames.length)];

    // Calculate center area bounds
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Rect centerArea = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2),
      width: 400,
      height: 400,
    );

    // Ensure fruits spawn within the center area
    Offset position = Offset(
      centerArea.left + random.nextDouble() * centerArea.width,
      centerArea.top + random.nextDouble() * centerArea.height,
    );
    // Adjust the force to throw the fruit upwards
    // Tweak these values as needed to get the desired effect
    Offset additionalForce = Offset(
      random.nextDouble() * 5 - 2.5, // Horizontal force
      -15 - random.nextDouble() * 10, // Vertical force, negative to go upwards
    );

    // Update the count for the spawned food
    foodSpawnCount[name] = (foodSpawnCount[name] ?? 0) + 1;
    // Print the count of each type of food spawned
    print("Food Spawn Count: $foodSpawnCount");

    _fruits.add(
      Fruit(
        position: position,
        width: 80,
        height: 80,
        name: name,
        additionalForce: additionalForce,
        rotation: random.nextDouble() / 3 - 0.16,
      ),
    );
  }

  void _tick() {
    if (!_isGamePaused) {
      setState(() {
        for (Fruit fruit in _fruits) {
          fruit.applyGravity();
        }
        for (FruitPart fruitPart in _fruitParts) {
          fruitPart.applyGravity();
        }

        if (Random().nextDouble() > 0.97) {
          _spawnRandomFruit();
        }
      });

      Future<void>.delayed(Duration(milliseconds: 30), _tick);

      // Check player's nutrition every 20 seconds
      int currentTime = (120 -
              (_countdownController.duration?.inSeconds ?? 0) *
                  _countdownController.value)
          .round();
      if (currentTime % 20 == 0 && currentTime != 0) {
        _checkPlayerNutrition();
      }

    }
  }

  Set<int> increasedTimes =
      {}; // Keep track of the times at which increases have occurred
  void _checkSurvival() {
    int currentTime = (120 -
            (_countdownController.duration?.inSeconds ?? 0) *
                _countdownController.value)
        .round();

    List<int> healthCheckPoints = [20, 40, 60, 80, 100];
    Set<int> checkedPoints = Set();

    // Check if current time is exactly on a checkpoint and not at the start of the game (currentTime > 0)
    if (healthCheckPoints.contains(currentTime) &&
        !checkedPoints.contains(currentTime) &&
        currentTime > 0) {
      _checkPlayerHealth();
      checkedPoints.add(currentTime); // Mark this time as checked
    }

    increasePercentages.forEach((time, percentage) {
      if (currentTime >= time && !increasedTimes.contains(time)) {
        maxWater *= (1 + percentage);
        maxEnergy *= (1 + percentage);
        maxProtein *= (1 + percentage);
        maxFat *= (1 + percentage);
        maxCarb *= (1 + percentage);
        maxFiber *= (1 + percentage);
        maxSugar *= (1 + percentage);
        maxCalcium *= (1 + percentage);
        maxIron *= (1 + percentage);
        maxMagnesium *= (1 + percentage);
        maxPhosphorus *= (1 + percentage);
        maxPotassium *= (1 + percentage);
        maxSodium *= (1 + percentage);
        maxZinc *= (1 + percentage);
        maxCopper *= (1 + percentage);
        maxManganese *= (1 + percentage);
        maxSelenium *= (1 + percentage);
        maxVc *= (1 + percentage);
        maxVb *= (1 + percentage);
        maxVa *= (1 + percentage);
        maxVd *= (1 + percentage);
        maxVk *= (1 + percentage);
        maxCaffeine *= (1 + percentage);
        maxAlcohol *= (1 + percentage);
        increasedTimes
            .add(time); // Mark this time as having increased the values
      }
    });

    _checkPlayerHealth();

    if (currentTime >= 120) {
      _endGame("Congrats!");
    }
  }

  void _pauseGame() {
    setState(() {
      _isGamePaused = !_isGamePaused;
      if (_isGamePaused) {
        _countdownController.stop();
      } else {
        _countdownController.reverse(from: _countdownController.value);
        _tick(); // Restart game loop
      }
    });
  }

  

  void _endGame(String message) {
    _pauseGame(); // Pause the game
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _saveHighScore(
                    _score); // Save the score if it's a high score
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int highScore = prefs.getInt('highScore') ?? 0;
    if (score > highScore) {
      await prefs.setInt('highScore', score);
    }
  }

  Future<int> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;

    // Adjust sizes and positions based on screen size
    double scoreFontSize = screenW * 0.02; // Example of responsive font size
    double buttonWidth = screenW * 0.12; // Example of responsive button width

    return Stack(
        children: _getStack(screenW, screenH, scoreFontSize, buttonWidth));
  }

  List<Widget> _getStack(double screenWidth, double screenHeight,
      double scoreFontSize, double buttonWidth) {
    List<Widget> widgetsOnStack = <Widget>[];

    widgetsOnStack.add(_getBackground());
    widgetsOnStack.add(_getSlice());
    widgetsOnStack.addAll(_getFruitParts());
    widgetsOnStack.addAll(_getFruits());
    widgetsOnStack.add(_getGestureDetector());
    const IconData not_started = IconData(0xe448, fontFamily: 'MaterialIcons');
    const IconData motion_photos_pause =
        IconData(0xe408, fontFamily: 'MaterialIcons');
    const IconData arrow_back_ios_new =
        IconData(0xe094, fontFamily: 'MaterialIcons', matchTextDirection: true);

    // Adjust the position and size of score text
    widgetsOnStack.add(
      Positioned(
        top: screenHeight * 0.06, // 2% of screen height from the top
        right: screenWidth * 0.05, // 5% of screen width from the right
        child: Text(
          'Score: $_score',
          style: TextStyle(fontSize: scoreFontSize),
        ),
      ),
    );

    // add (countdown) progress bar to the canvas area
    widgetsOnStack.add(
      Positioned(
        top: screenHeight * .06,
        left: screenWidth * .5,
        child: Row(
          children: [
            // Wrap the progress bar with a SizedBox or Container
            SizedBox(
              width: screenWidth * .25, // Set the width as per your requirement
              height: screenHeight * .02,
              child: LinearProgressIndicator(
                value: _countdownController.value,
                backgroundColor: Colors.grey[150],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            SizedBox(width: 10),
            Text(countdownText, style: TextStyle(fontSize: scoreFontSize)),
          ],
        ),
      ),
    );

    // Add Exit button
    widgetsOnStack.add(
      Positioned(
          top: screenHeight * .02,
          left: screenWidth * .02,
          child: SizedBox(
            width: screenWidth * .1,
            height: screenHeight * .1,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Navigate back to the game menu
              },
              child: Icon(arrow_back_ios_new),
            ),
          )),
    );

    // Adjust the position and size of PAUSE button
    widgetsOnStack.add(
      Positioned(
        top: screenHeight * 0.02,
        left: screenWidth * 0.13, // Adjusted for better spacing
        child: SizedBox(
          width: screenWidth * .1,
          height: screenHeight * .1,
          child: ElevatedButton(
            onPressed: () => _pauseGame(),
            child: Icon(_isGamePaused ? not_started : motion_photos_pause),
          ),
        ),
      ),
    );

    return widgetsOnStack;
  }

  Container _getBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          stops: <double>[0.2, 1.0],
          colors: <Color>[Color(0xffBFEEF4), Color(0xff3FCCDE)],
        ),
      ),
    );
  }

  Widget _getSlice() {
    if (_touchSlice == null) {
      return Container();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: SlicePainter(
        pointsList: _touchSlice!.pointsList,
      ),
    );
  }

  List<Widget> _getFruits() {
    List<Widget> list = <Widget>[];

    for (Fruit fruit in _fruits) {
      list.add(
        Positioned(
          top: fruit.position.dy,
          left: fruit.position.dx,
          child: Transform.rotate(
            angle: fruit.rotation * pi * 2,
            child: _getFruitWidget(fruit),
          ),
        ),
      );
    }

    return list;
  }

  Widget _getFruitWidget(Fruit fruit) {
    switch (fruit.name) {
      case 'apple':
        return _getApple(fruit);
      case 'banana':
        return _getBanana(fruit);
      case 'avocado':
        return _getAvocado(fruit);
      default: // 'melon'
        return _getMelon(fruit);
    }
  }

  List<Widget> _getFruitParts() {
    List<Widget> list = <Widget>[];

    for (FruitPart fruitPart in _fruitParts) {
      list.add(
        Positioned(
          top: fruitPart.position.dy,
          left: fruitPart.position.dx,
          // child: _getMelonCut(fruitPart),
          child: _getCutFruit(fruitPart),
        ),
      );
    }

    return list;
  }

  Widget _getCutFruit(FruitPart fruitPart) {
    String assetName;
    switch (fruitPart.fruitName) {
      // Assuming fruitType is a property of FruitPart
      case 'apple':
        assetName = fruitPart.isLeft
            ? 'assets/apple_cut_left.png'
            : 'assets/apple_cut_right.png';
        break;
      case 'banana':
        assetName = fruitPart.isLeft
            ? 'assets/banana_cut_left.png'
            : 'assets/banana_cut_right.png';
        break;
      case 'avocado':
        assetName = fruitPart.isLeft
            ? 'assets/avocado_cut_left.png'
            : 'assets/avocado_cut_right.png';
        break;
      default: // 'melon'
        assetName = fruitPart.isLeft
            ? 'assets/melon_cut_left.png'
            : 'assets/melon_cut_right.png';
        break;
    }

    return Transform.rotate(
        angle: fruitPart.rotation * pi * 2,
        child: Image.asset(
          assetName,
          height: 80,
          fit: BoxFit.fitHeight,
        ));
  }

  Widget _getMelon(Fruit fruit) {
    return Image.asset(
      'assets/melon_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBanana(Fruit fruit) {
    return Image.asset(
      'assets/banana_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getApple(Fruit fruit) {
    return Image.asset(
      'assets/apple_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getAvocado(Fruit fruit) {
    return Image.asset(
      'assets/avocado_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getGestureDetector() {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        setState(() => _setNewSlice(details));
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        setState(
          () {
            _addPointToSlice(details);
            _checkCollision();
          },
        );
      },
      onScaleEnd: (ScaleEndDetails details) {
        setState(() => _resetSlice());
      },
    );
  }

  _checkCollision() {
    if (_isGamePaused) return; // Do nothing if the game is paused
    if (_touchSlice == null) {
      return;
    }

    for (Fruit fruit in List<Fruit>.from(_fruits)) {
      bool firstPointOutside = false;
      bool secondPointInside = false;

      for (Offset point in _touchSlice!.pointsList) {
        if (!firstPointOutside && !fruit.isPointInside(point)) {
          firstPointOutside = true;
          continue;
        }

        if (firstPointOutside && fruit.isPointInside(point)) {
          secondPointInside = true;
          continue;
        }

        if (secondPointInside && !fruit.isPointInside(point)) {
          _fruits.remove(fruit);
          _turnFruitIntoParts(fruit);
          _score += 10;

          // update player's nutrition
          _updatePlayerNutrition(fruit.name);

          // handle fruit cut:
          if (fruit.name == 'melon') {
            _melonsCut++;
          } else if (fruit.name == 'banana') {
            _bananaCut++;
          } else if (fruit.name == 'apple') {
            _appleCut++;
          } else if (fruit.name == 'avocado') {
            _avocadoCut++;
          }
          break;
        }
      }
    }
  }

  void _turnFruitIntoParts(Fruit hit) {
    FruitPart leftFruitPart = FruitPart(
      position: Offset(
        hit.position.dx - hit.width / 8,
        hit.position.dy,
      ),
      width: hit.width / 2,
      height: hit.height,
      isLeft: true,
      fruitName: hit.name,
      gravitySpeed: hit.gravitySpeed,
      additionalForce: Offset(
        hit.additionalForce.dx - 1,
        hit.additionalForce.dy - 5,
      ),
      rotation: hit.rotation,
    );

    FruitPart rightFruitPart = FruitPart(
      position: Offset(
        hit.position.dx + hit.width / 4 + hit.width / 8,
        hit.position.dy,
      ),
      width: hit.width / 2,
      height: hit.height,
      isLeft: false,
      fruitName: hit.name,
      gravitySpeed: hit.gravitySpeed,
      additionalForce: Offset(
        hit.additionalForce.dx + 1,
        hit.additionalForce.dy - 5,
      ),
      rotation: hit.rotation,
    );

    setState(() {
      _fruitParts.add(leftFruitPart);
      _fruitParts.add(rightFruitPart);
      _fruits.remove(hit);
    });
  }

  void _resetSlice() {
    _touchSlice = null;
  }

  void _setNewSlice(ScaleStartDetails details) {
    if (_isGamePaused) return; // Do nothing if the game is paused
    setState(() {
      _touchSlice = TouchSlice(pointsList: [details.localFocalPoint]);
    });
  }

  void _addPointToSlice(ScaleUpdateDetails details) {
    if (_isGamePaused) return; // Do nothing if the game is paused

    if (_touchSlice?.pointsList == null || _touchSlice!.pointsList.isEmpty) {
      return;
    }

    if (_touchSlice!.pointsList.length > 16) {
      _touchSlice!.pointsList.removeAt(0);
    }
    _touchSlice!.pointsList.add(details.localFocalPoint);
  }

  void _updatePlayerNutrition(String fruitName) {
    final nutrition = foodNutritions[fruitName];
    if (nutrition != null) {
      player.water += nutrition['water'] ?? 0;
      player.energy += nutrition['energy'] ?? 0;
      player.protein += nutrition['protein'] ?? 0;
      player.fat += nutrition['fat'] ?? 0;
      player.carb += nutrition['carb'] ?? 0;
      player.fiber += nutrition['fiber'] ?? 0;
      player.sugar += nutrition['sugar'] ?? 0;
      player.calcium += nutrition['calcium'] ?? 0;
      player.iron += nutrition['iron'] ?? 0;
      player.magnesium += nutrition['magnesium'] ?? 0;
      player.phosphorus += nutrition['phosphorus'] ?? 0;
      player.potassium += nutrition['potassium'] ?? 0;
      player.sodium += nutrition['sodium'] ?? 0;
      player.zinc += nutrition['zinc'] ?? 0;
      player.copper += nutrition['copper'] ?? 0;
      player.manganese += nutrition['manganese'] ?? 0;
      player.selenium += nutrition['selenium'] ?? 0;
      player.vc += nutrition['vc'] ?? 0;
      player.vb += nutrition['vb'] ?? 0;
      player.va += nutrition['va'] ?? 0;
      player.vd += nutrition['vd'] ?? 0;
      player.vk += nutrition['vk'] ?? 0;
      player.caffeine += nutrition['caffeine'] ?? 0;
      player.alcohol += nutrition['alcohol'] ?? 0;

      // print('updated nutritions: ' + nutrition.toString());
    }
    // Print updated nutrition values
    print("Updated Player Nutrition:");
    print("Water: ${player.water}");
    print("Energy: ${player.energy}");
    print("Protein: ${player.protein}");
  }

  void _checkPlayerHealth() {
    if (player.water > maxWater ||
        player.energy > maxEnergy ||
        player.protein > maxProtein ||
        player.fat > maxFat ||
        player.carb > maxCarb ||
        player.fiber > maxFiber ||
        player.sugar > maxSugar ||
        player.calcium > maxCalcium ||
        player.iron > maxIron ||
        player.magnesium > maxMagnesium ||
        player.phosphorus > maxPhosphorus ||
        player.potassium > maxPotassium ||
        player.sodium > maxSodium ||
        player.zinc > maxZinc ||
        player.copper > maxCopper ||
        player.manganese > maxManganese ||
        player.selenium > maxSelenium ||
        player.vc > maxVc ||
        player.vb > maxVb ||
        player.va > maxVa ||
        player.vd > maxVd ||
        player.vk > maxVk ||
        player.caffeine > maxCaffeine ||
        player.alcohol > maxAlcohol) {
      _endGame("You died due to over-nutrition!");
    } else if (player.water < minWater ||
        player.energy < minEnergy ||
        player.protein < minProtein ||
        player.fat < minFat ||
        player.carb < minCarb ||
        player.fiber < minFiber ||
        player.sugar < minSugar ||
        player.calcium < minCalcium ||
        player.iron < minIron ||
        player.magnesium < minMagnesium ||
        player.phosphorus < minPhosphorus ||
        player.potassium < minPotassium ||
        player.sodium < minSodium ||
        player.zinc < minZinc ||
        player.copper < minCopper ||
        player.manganese < minManganese ||
        player.selenium < minSelenium ||
        player.vc < minVc ||
        player.vb < minVb ||
        player.va < minVa ||
        player.vd < minVd ||
        player.vk < minVk ||
        player.caffeine < minCaffeine ||
        player.alcohol < minAlcohol) {
      _endGame("You died due to under-nutrition!");
    }
  }

  void _checkPlayerNutrition() {
    bool isMalnutrition = _isBelowMinNutrition();
    bool isOvernutrition = _isAboveMaxNutrition();

    if (isMalnutrition) {
      _endGame("Malnutrition!");
    } else if (isOvernutrition) {
      _endGame("Overnutrition!");
    }
  }

  bool _isBelowMinNutrition() {
    return player.water < minWater || player.energy < minEnergy || player.protein < minProtein;
    // Add checks for other nutrients
  }

  bool _isAboveMaxNutrition() {
    return player.water > maxWater || player.energy > maxEnergy || player.protein > maxProtein;
    // Add checks for other nutrients
  }
  
}
