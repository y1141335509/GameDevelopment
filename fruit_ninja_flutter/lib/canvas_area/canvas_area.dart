import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import 'package:csv/csv.dart';
import 'models/fruit.dart';
import './models/body.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
import 'slice_painter.dart';
import '../db_initializer.dart';

////////////////////////////////////////////
///                                      ///
///                                      ///
// var db_initializer = DBInitializer();
// var db = db_initializer.database;
Future<List<String>> names = DBInitializer().queryAllFoodNames();

///                                      ///
///                                      ///
////////////////////////////////////////////

// fruitsCut defines the number of each fruit type is cut after game play.
Map<String, int> foodSpawnCount = {};

// Map<String, Map<String, double>> foodNutritions = {
//   "melon": {
//     "water": 4130.0,
//     "energy": 1360.0,
//     "protein": 27.6,
//     "fat": 6.78,
//     "carb": 341,
//     "fiber": 18.1,
//     "sugar": 280,
//     "calcium": 316,
//     "iron": 10.8,
//     "magnesium": 452,
//     "phosphorus": 497,
//     "potassium": 5060,
//     "sodium": 45.2,
//     "zinc": 4.52,
//     "copper": 1.9,
//     "manganese": 1.72,
//     "selenium": 18.1,
//     "vc": 366,
//     "vb": 2.03,
//     "va": 1270,
//     "vd": 0,
//     "vk": 4.52,
//     "caffeine": 0,
//     "alcohol": 0
//   },
//   "apple": {
//     "water": 83.6,
//     "energy": 65,
//     "protein": 0.15,
//     "fat": 0.16,
//     "carb": 15.6,
//     "fiber": 2.1,
//     "sugar": 13.3,
//     "calcium": 6,
//     "iron": 0.02,
//     "magnesium": 4.7,
//     "phosphorus": 10,
//     "potassium": 104,
//     "sodium": 1,
//     "zinc": 0.02,
//     "copper": 0.033,
//     "manganese": 0.033,
//     "selenium": 0,
//     "vc": 5.7,
//     "vb": 0.045,
//     "va": 2,
//     "vd": 0,
//     "vk": 1,
//     "caffeine": 0,
//     "alcohol": 0
//   },
//   "banana": {
//     "water": 75.3,
//     "energy": 98,
//     "protein": 0.74,
//     "fat": 0.29,
//     "carb": 23,
//     "fiber": 1.7,
//     "sugar": 15.8,
//     "calcium": 5,
//     "iron": 0.4,
//     "magnesium": 28,
//     "phosphorus": 22,
//     "potassium": 326,
//     "sodium": 4,
//     "zinc": 0.16,
//     "copper": 0.101,
//     "manganese": 0.258,
//     "selenium": 2.5,
//     "vc": 12.3,
//     "vb": 0.209,
//     "va": 1,
//     "vd": 0,
//     "vk": 0.1,
//     "caffeine": 0,
//     "alcohol": 0
//   },
//   "avocado": {
//     "water": 73.2,
//     "energy": 160,
//     "protein": 670,
//     "fat": 14.7,
//     "carb": 8.53,
//     "fiber": 6.7,
//     "sugar": 0.66,
//     "calcium": 12,
//     "iron": 0.55,
//     "magnesium": 29,
//     "phosphorus": 52,
//     "potassium": 485,
//     "sodium": 7,
//     "zinc": 0.64,
//     "copper": 0.19,
//     "manganese": 0.142,
//     "selenium": 0.4,
//     "vc": 10,
//     "vb": 0.257,
//     "va": 7,
//     "vd": 0,
//     "vk": 21,
//     "caffeine": 0,
//     "alcohol": 0
//   }
// };

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
  int _broccoliCut = 0;
  int _pinkSalmonCut = 0;
  int _chickenCut = 0;


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

  // for audios:
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    //// Audios:
    // AssetsAudioPlayer.newPlayer().open(
    //   Audio("assets/audios/lemonjuicysqueezefruit-77998.mp3"),
    //   autoStart: true,
    //   showNotification: true,
    // );
    //// Audios

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

  void _spawnRandomFruit() async {
    final random = Random();
    List<String> foodNames = [
      'watermelon',
      'apple',
      'banana',
      'avocado',
      'broccoli',
      'pink salmon',
      'chicken',
    ];
    String name = foodNames[random.nextInt(foodNames.length)];

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
    for (String foodName in foodNames) {
      foodSpawnCount[foodName] = 0;
    }
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
        // _checkPlayerNutrition();
        _checkPlayerHealth();
      }
    }
  }

  Set<int> increasedTimes =
      {}; // Keep track of the times at which increases have occurred
  void _checkSurvival() async {
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

    final upper = await DBInitializer().queryFoodNutritionByName('upper');
    increasePercentages.forEach((time, percentage) {
      if (currentTime >= time && !increasedTimes.contains(time)) {
        upper.forEach((element) {
          element['WATER'] *= (1 + percentage);
          element['ENERGY'] *= (1 + percentage);
          element['PROTEIN'] *= (1 + percentage);
          element['FAT'] *= (1 + percentage);
          element['CARB'] *= (1 + percentage);
          element['FIBER'] *= (1 + percentage);
          element['SUGAR'] *= (1 + percentage);
          element['CALCIUM'] *= (1 + percentage);
          element['IRON'] *= (1 + percentage);
          element['MAGNESIUM'] *= (1 + percentage);
          element['PHOSPHORUS'] *= (1 + percentage);
          element['POTASSIUM'] *= (1 + percentage);
          element['SODIUM'] *= (1 + percentage);
          element['ZINC'] *= (1 + percentage);
          element['COPPER'] *= (1 + percentage);
          element['MANGANESE'] *= (1 + percentage);
          element['SELENIUM'] *= (1 + percentage);
          element['VC'] *= (1 + percentage);
          element['VB'] *= (1 + percentage);
          element['VA'] *= (1 + percentage);
          element['VD'] *= (1 + percentage);
          element['VK'] *= (1 + percentage);
          element['CAFFEINE'] *= (1 + percentage);
          element['ALCOHOL'] *= (1 + percentage);
        });
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
      case 'broccoli':
        return _getBroccoli(fruit);
      case 'pink salmon':
        return _getPinkSalmon(fruit);
      case 'chicken':
        return _getChicken(fruit);
      default: // 'watermelon'
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
      case 'broccoli':
        assetName = fruitPart.isLeft
            ? 'assets/broccoli_cut_left.png'
            : 'assets/broccoli_cut_right.png';
        break;
      case 'pink salmon':
        assetName = fruitPart.isLeft
            ? 'assets/pink_salmon_cut_left.png'
            : 'assets/pink_salmon_cut_right.png';
        break;
      case 'chicken':
        assetName = fruitPart.isLeft
            ? 'assets/chicken_cut_left.png'
            : 'assets/chicken_cut_right.png';
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

  Widget _getBroccoli(Fruit fruit) {
    return Image.asset(
      'assets/broccoli_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getPinkSalmon(Fruit fruit) {
    return Image.asset(
      'assets/pink_salmon_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getChicken(Fruit fruit) {
    return Image.asset(
      'assets/chicken_uncut.png',
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

          //// Audios:
          // AssetsAudioPlayer.newPlayer().open(
          //   Audio("assets/audios/lemonjuicysqueezefruit-77998.mp3"),
          //   autoStart: true,
          //   showNotification: true,
          // );

          //// Audios

          // handle fruit cut:
          if (fruit.name == 'melon') {
            _melonsCut++;
          } else if (fruit.name == 'banana') {
            _bananaCut++;
          } else if (fruit.name == 'apple') {
            _appleCut++;
          } else if (fruit.name == 'avocado') {
            _avocadoCut++;
          } else if (fruit.name == 'broccoli') {
            _broccoliCut++;
          } else if (fruit.name == 'pink salmon') {
            _pinkSalmonCut++;
          } else if (fruit.name == 'chicken') {
            _chickenCut++;
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

  void _updatePlayerNutrition(String fruitName) async {
    ////////////////////////////////////
    ///           TESTING            ///
    // List<Map<dynamic, dynamic>> m = await DBInitializer().queryFoodNutritions();
    // m looks like:
    // [{}]
    // for (int i = 0; i < m.length; i++) {
    //   print('mapp: ' + m[i].toString());
    //   for (String key in m[i].keys) {
    //     print('key: ' + key.toString() + " ---> " + m[i][key].toString());
    //   }
    // }

    ///           TESTING            ///
    ////////////////////////////////////

    final nutrition = await DBInitializer().queryFoodNutritionByName(fruitName);
    if (nutrition != null) {
      player.water += nutrition[0]['WATER'] ?? 0;
      player.energy += nutrition[0]['ENERGY'] ?? 0;
      player.protein += nutrition[0]['PROTEIN'] ?? 0;
      player.fat += nutrition[0]['FAT'] ?? 0;
      player.carb += nutrition[0]['CARB'] ?? 0;
      player.fiber += nutrition[0]['FIBER'] ?? 0;
      player.sugar += nutrition[0]['SUGAR'] ?? 0;
      player.calcium += nutrition[0]['CALCIUM'] ?? 0;
      player.iron += nutrition[0]['IRON'] ?? 0;
      player.magnesium += nutrition[0]['MAGNESIUM'] ?? 0;
      player.phosphorus += nutrition[0]['PHOSPHORUS'] ?? 0;
      player.potassium += nutrition[0]['POTASSIUM'] ?? 0;
      player.sodium += nutrition[0]['SODIUM'] ?? 0;
      player.zinc += nutrition[0]['ZINC'] ?? 0;
      player.copper += nutrition[0]['COPPER'] ?? 0;
      player.manganese += nutrition[0]['MANGANESE'] ?? 0;
      player.selenium += nutrition[0]['SELENIUM'] ?? 0;
      player.vc += nutrition[0]['VC'] ?? 0;
      player.vb += nutrition[0]['VB'] ?? 0;
      player.va += nutrition[0]['VA'] ?? 0;
      player.vd += nutrition[0]['VD'] ?? 0;
      player.vk += nutrition[0]['VK'] ?? 0;
      player.caffeine += nutrition[0]['CAFFEINE'] ?? 0;
      player.alcohol += nutrition[0]['ALCOHOL'] ?? 0;
    }
  }

  void _checkPlayerHealth() async {
    final upper = await DBInitializer().queryFoodNutritionByName('upper');
    final lower = await DBInitializer().queryFoodNutritionByName('lower');
    if (player.water > upper[0]['WATER'] ||
        player.energy > upper[0]['ENERGY'] ||
        player.protein > upper[0]['PROTEIN'] ||
        player.fat > upper[0]['FAT'] ||
        player.carb > upper[0]['CARB'] ||
        player.fiber > upper[0]['FIBER'] ||
        player.sugar > upper[0]['SUGAR'] ||
        player.calcium > upper[0]['CALCIUM'] ||
        player.iron > upper[0]['IRON'] ||
        player.magnesium > upper[0]['MAGNESIUM'] ||
        player.phosphorus > upper[0]['PHOSPHORUS'] ||
        player.potassium > upper[0]['POTASSIUM'] ||
        player.sodium > upper[0]['SODIUM'] ||
        player.zinc > upper[0]['ZINC'] ||
        player.copper > upper[0]['COPPER'] ||
        player.manganese > upper[0]['MANGANESE'] ||
        player.selenium > upper[0]['SELENIUM'] ||
        player.vc > upper[0]['VC'] ||
        player.vb > upper[0]['VB'] ||
        player.va > upper[0]['VA'] ||
        player.vd > upper[0]['VD'] ||
        player.vk > upper[0]['VK'] ||
        player.caffeine > upper[0]['CAFFEINE'] ||
        player.alcohol > upper[0]['ALCOHOL']) {
      _endGame("You died due to over-nutrition!");
    } else if (player.water > lower[0]['WATER'] ||
        player.energy > lower[0]['ENERGY'] ||
        player.protein > lower[0]['PROTEIN'] ||
        player.fat > lower[0]['FAT'] ||
        player.carb > lower[0]['CARB'] ||
        player.fiber > lower[0]['FIBER'] ||
        player.sugar > lower[0]['SUGAR'] ||
        player.calcium > lower[0]['CALCIUM'] ||
        player.iron > lower[0]['IRON'] ||
        player.magnesium > lower[0]['MAGNESIUM'] ||
        player.phosphorus > lower[0]['PHOSPHORUS'] ||
        player.potassium > lower[0]['POTASSIUM'] ||
        player.sodium > lower[0]['SODIUM'] ||
        player.zinc > lower[0]['ZINC'] ||
        player.copper > lower[0]['COPPER'] ||
        player.manganese > lower[0]['MANGANESE'] ||
        player.selenium > lower[0]['SELENIUM'] ||
        player.vc > lower[0]['VC'] ||
        player.vb > lower[0]['VB'] ||
        player.va > lower[0]['VA'] ||
        player.vd > lower[0]['VD'] ||
        player.vk > lower[0]['VK'] ||
        player.caffeine > lower[0]['CAFFEINE'] ||
        player.alcohol > lower[0]['ALCOHOL']) {
      _endGame("You died due to under-nutrition!");
    }
  }

  // void _checkPlayerNutrition() {
  //   bool isMalnutrition = _isBelowMinNutrition();
  //   bool isOvernutrition = _isAboveMaxNutrition();

  //   if (isMalnutrition) {
  //     _endGame("Malnutrition!");
  //   } else if (isOvernutrition) {
  //     _endGame("Overnutrition!");
  //   }
  // }

  // bool _isBelowMinNutrition() {
  //   return player.water < minWater ||
  //       player.energy < minEnergy ||
  //       player.protein < minProtein;
  //   // Add checks for other nutrients
  // }

  // bool _isAboveMaxNutrition() {
  //   return player.water > maxWater ||
  //       player.energy > maxEnergy ||
  //       player.protein > maxProtein;
  //   // Add checks for other nutrients
  // }
}
