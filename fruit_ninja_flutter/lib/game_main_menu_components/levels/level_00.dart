import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:audioplayers/audioplayers.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';

import 'models/fruit.dart';
import 'models/body.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'slice_painter.dart';
import '../../db_initializer.dart';

Future<List<String>> names = DBInitializer().queryAllFoodNames();

// fruitsCut defines the number of each fruit type is cut after game play.
Map<String, int> foodSpawnCount = {};

late Body player; // Instance to hold player's state

class CanvasAreaLevel_00 extends StatefulWidget {
  final int level;

  const CanvasAreaLevel_00({Key? key, required this.level}) : super(key: key); // Added required for level

  @override
  _CanvasAreaState createState() => _CanvasAreaState();
}


class _CanvasAreaState extends State<CanvasAreaLevel_00> with TickerProviderStateMixin {
  int _score = 0;
  TouchSlice? _touchSlice;
  final List<Fruit> _fruits = <Fruit>[];
  final List<FruitPart> _fruitParts = <FruitPart>[];
  late AnimationController _countdownController;
  bool _isGamePaused = false;

  int _melonsCut = 0; // number of melons cut
  int _bananaCut = 0;
  int _appleCut = 0;
  int _avocadoCut = 0;
  int _broccoliCut = 0;
  int _pinkSalmonCut = 0;
  int _chickenCut = 0;
  int _beefCut = 0;
  int _arugulaCut = 0;
  int _breadCut = 0;
  int _eggCut = 0;
  int _cornCut = 0;
  int _beerCut = 0;
  int _vodkaCut = 0;
  int _coffeeCut = 0;
  int _noodlesCut = 0;
  int _riceCut = 0;
  int _milkCut = 0;
  int _yogurtCut = 0;
  int _tofuCut = 0;
  int _muffinCut = 0;
  int _cornOilCut = 0;
  int _mangoCut = 0;
  int _cilantroCut = 0;
  int _sugarCut = 0;
  int _soyMilkCut = 0;
  int _carrotCut = 0;
  int _pumpkinCut = 0;
  int _potatoCut = 0;


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
    _countdownController.addStatusListener((status) async {
      if (status == AnimationStatus.dismissed) {
        // _endGame("Time's up!");
        final diseases = await _getNutrientRelatedDiseases();
        _endGame(diseases);
      }
    });

    // Start the countdown
    _countdownController.reverse(from: 1.0);

    // Initialize the player with default nutritional values
    player = Body(
        id: 0, // If id is not relevant at the moment, you can set it to 0 or any default value
        water: 0, // Default water value
        energy: 0, // Default energy value
        protein: 0, // Default protein value
        fat: 0,
        carb: 0,
        fiber: 0,
        sugar: 0,
        calcium: 0,
        iron: 0,
        magnesium: 0,
        phosphorus: 0,
        potassium: 0,
        sodium: 0,
        zinc: 0,
        copper: 0,
        manganese: 0,
        selenium: 0,
        vc: 0,
        vb: 0,
        va: 0,
        vd: 0,
        vk: 0,
        caffeine: 0,
        alcohol: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spawnRandomFood();
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

  Map<String, int> foodSpawnConfig = {
    'watermelon': 0,
    'apple': 0,
    'banana': 30,
    'avocado': 0,
    'broccoli': 2,
    'pink salmon': 2,
    'chicken': 0,
    'beef': 5,
    'arugula': 4,
    'bread': 2,
    'egg': 30,
    'corn': 29,
    'beer': 1,
    'vodka': 0,
    'coffee': 1,
    'noodles': 0,
    'rice': 0,
    'milk': 0,
    'yogurt': 0,
    'tofu': 16,
    'muffin': 0,
    'corn oil': 18,
    'mango': 0,
    'cilantro': 5,
    'sugar': 0,
    'soy milk': 0,
    'carrot': 30,
    'pumpkin': 8,
    'potato': 1,
  };

  late Timer _spawnTimer;

  void _spawnRandomFood() {
    String randomFood = _getRandomFoodName();
    _spawnSingleFood(randomFood);
    int elapsedTime = (120 -
            (_countdownController.duration?.inSeconds ?? 0) *
                _countdownController.value)
        .round();
    int spawnInterval = 20; // Interval for checking spawn configuration

    if (elapsedTime % spawnInterval == 0 && elapsedTime <= 120) {
      // Only do this in the first 60 seconds
      int totalSpawnCountFor20Secs =
          _calculateTotalSpawnForNext20Secs(elapsedTime);
      int spawnsPerSecond = totalSpawnCountFor20Secs ~/ 20;

      _spawnTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        for (int i = 0; i < spawnsPerSecond; i++) {
          String randomFood = _getRandomFoodName();
          _spawnSingleFood(randomFood);
        }

        // Stop the timer after 20 seconds
        if (timer.tick >= 20) {
          timer.cancel();
        }
      });
    }
  }

  int _calculateTotalSpawnForNext20Secs(int elapsedTime) {
    int total = 0;
    foodSpawnConfig.forEach((name, count) {
      total += (count ~/ 6); // Divide by 3 to get count for 20 seconds
    });
    return total;
  }

  String _getRandomFoodName() {
    Random random = Random();
    List<String> foodNames = foodSpawnConfig.keys.toList();
    return foodNames[random.nextInt(foodNames.length)];
  }

  void _spawnSingleFood(String name) {
    final random = Random();

    // Calculate center area bounds
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Rect centerArea = Rect.fromCenter(
      center: Offset(screenWidth / 2, screenHeight / 2),
      width: 400,
      height: 400,
    );

    // Ensure food spawns within the center area
    Offset position = Offset(
      centerArea.left + random.nextDouble() * centerArea.width,
      centerArea.top + random.nextDouble() * centerArea.height,
    );

    // Adjust the force to throw the food upwards
    Offset additionalForce = Offset(
      random.nextDouble() * 5 - 2.5,
      -15 - random.nextDouble() * 10,
    );

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
          _spawnRandomFood();
        }
      });

      int currentTime = (120 -
              (_countdownController.duration?.inSeconds ?? 0) *
                  _countdownController.value)
          .round();

      if (currentTime >= 120) {
        List<String> win = [];
        win.add("Congrats!");
        _endGame(win);
      } else if (currentTime % 20 == 0 && currentTime > 0) {
        _checkPlayerHealth(currentTime);
      }

      Future<void>.delayed(Duration(milliseconds: 30), _tick);
    }
  }

  Set<int> increasedTimes =
      {}; // Keep track of the times at which increases have occurred

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

  void _endGame(List<String> diseases) {
    _pauseGame(); // Pause the game
    String message = diseases.join(", ");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("You died due to: $message"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _saveHighScore(_score);
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
      case 'beef':
        return _getBeef(fruit);
      case 'arugula':
        return _getArugula(fruit);
      case 'bread':
        return _getBread(fruit);
      case 'egg':
        return _getEgg(fruit);
      case 'corn':
        return _getCorn(fruit);
      case 'beer':
        return _getBeer(fruit);
      case 'vodka':
        return _getVodka(fruit);
      case 'coffee':
        return _getCoffee(fruit);
      case 'noodles':
        return _getNoodles(fruit);
      case 'rice':
        return _getRice(fruit);
      case 'milk':
        return _getMilk(fruit);
      case 'yogurt':
        return _getYogurt(fruit);
      case 'tofu':
        return _getTofu(fruit);
      case 'muffin':
        return _getMuffin(fruit);
      case 'corn oil':
        return _getCornOil(fruit);
      case 'mango':
        return _getMango(fruit);
      case 'cilantro':
        return _getCilantro(fruit);
      case 'sugar':
        return _getSugar(fruit);
      case 'soy milk':
        return _getSoyMilk(fruit);
      case 'carrot':
        return _getCarrot(fruit);
      case 'pumpkin':
        return _getPumpkin(fruit);
      case 'potato':
        return _getPotato(fruit);
      default: // 'watermelon'
        return _getWatermelon(fruit);
    }
  }

  List<Widget> _getFruitParts() {
    List<Widget> list = <Widget>[];

    for (FruitPart fruitPart in _fruitParts) {
      list.add(
        Positioned(
          top: fruitPart.position.dy,
          left: fruitPart.position.dx,
          // child: _getWatermelonCut(fruitPart),
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
            ? 'assets/images//apple_cut_left.png'
            : 'assets/images//apple_cut_right.png';
        break;
      case 'banana':
        assetName = fruitPart.isLeft
            ? 'assets/images/banana_cut_left.png'
            : 'assets/images/banana_cut_right.png';
        break;
      case 'avocado':
        assetName = fruitPart.isLeft
            ? 'assets/images/avocado_cut_left.png'
            : 'assets/images/avocado_cut_right.png';
        break;
      case 'broccoli':
        assetName = fruitPart.isLeft
            ? 'assets/images/broccoli_cut_left.png'
            : 'assets/images/broccoli_cut_right.png';
        break;
      case 'pink salmon':
        assetName = fruitPart.isLeft
            ? 'assets/images/pink_salmon_cut_left.png'
            : 'assets/images/pink_salmon_cut_right.png';
        break;
      case 'chicken':
        assetName = fruitPart.isLeft
            ? 'assets/images/chicken_cut_left.png'
            : 'assets/images/chicken_cut_right.png';
        break;
      case 'beef':
        assetName = fruitPart.isLeft
            ? 'assets/images/beef_cut_left.png'
            : 'assets/images/beef_cut_right.png';
        break;
      case 'arugula':
        assetName = fruitPart.isLeft
            ? 'assets/images/arugula_cut_left.png'
            : 'assets/images/arugula_cut_right.png';
        break;
      case 'bread':
        assetName = fruitPart.isLeft
            ? 'assets/images/bread_cut_left.png'
            : 'assets/images/bread_cut_right.png';
        break;
      case 'egg':
        assetName = fruitPart.isLeft
            ? 'assets/images/egg_cut_left.png'
            : 'assets/images/egg_cut_right.png';
        break;
      case 'corn':
        assetName = fruitPart.isLeft
            ? 'assets/images/corn_cut_left.png'
            : 'assets/images/corn_cut_right.png';
        break;
      case 'beer':
        assetName = fruitPart.isLeft
            ? 'assets/images/beer_cut_left.png'
            : 'assets/images/beer_cut_right.png';
        break;
      case 'vodka':
        assetName = fruitPart.isLeft
            ? 'assets/images/vodka_cut_left.png'
            : 'assets/images/vodka_cut_right.png';
        break;
      case 'coffee':
        assetName = fruitPart.isLeft
            ? 'assets/images/coffee_cut_left.png'
            : 'assets/images/coffee_cut_right.png';
        break;
      case 'noodles':
        assetName = fruitPart.isLeft
            ? 'assets/images/noodles_cut_left.png'
            : 'assets/images/noodles_cut_right.png';
        break;
      case 'rice':
        assetName = fruitPart.isLeft
            ? 'assets/images/rice_cut_left.png'
            : 'assets/images/rice_cut_right.png';
        break;
      case 'milk':
        assetName = fruitPart.isLeft
            ? 'assets/images/milk_cut_left.png'
            : 'assets/images/milk_cut_right.png';
        break;
      case 'yogurt':
        assetName = fruitPart.isLeft
            ? 'assets/images/yogurt_cut_left.png'
            : 'assets/images/yogurt_cut_right.png';
        break;
      case 'tofu':
        assetName = fruitPart.isLeft
            ? 'assets/images/tofu_cut_left.png'
            : 'assets/images/tofu_cut_right.png';
        break;
      case 'muffin':
        assetName = fruitPart.isLeft
            ? 'assets/images/muffin_cut_left.png'
            : 'assets/images/muffin_cut_right.png';
        break;
      case 'corn oil':
        assetName = fruitPart.isLeft
            ? 'assets/images/corn_oil_cut_left.png'
            : 'assets/images/corn_oil_cut_right.png';
        break;
      case 'mango':
        assetName = fruitPart.isLeft
            ? 'assets/images/mango_cut_left.png'
            : 'assets/images/mango_cut_right.png';
        break;
      case 'cilantro':
        assetName = fruitPart.isLeft
            ? 'assets/images/cilantro_cut_left.png'
            : 'assets/images/cilantro_cut_right.png';
        break;
      case 'sugar':
        assetName = fruitPart.isLeft
            ? 'assets/images/sugar_cut_left.png'
            : 'assets/images/sugar_cut_right.png';
        break;
      case 'soy milk':
        assetName = fruitPart.isLeft
            ? 'assets/images/soy_milk_cut_left.png'
            : 'assets/images/soy_milk_cut_right.png';
        break;
      case 'carrot':
        assetName = fruitPart.isLeft
            ? 'assets/images/carrot_cut_left.png'
            : 'assets/images/carrot_cut_right.png';
        break;
      case 'pumpkin':
        assetName = fruitPart.isLeft
            ? 'assets/images/pumpkin_cut_left.png'
            : 'assets/images/pumpkin_cut_right.png';
        break;
      case 'potato':
        assetName = fruitPart.isLeft
            ? 'assets/images/potato_cut_left.png'
            : 'assets/images/potato_cut_right.png';
        break;
      default: // 'melon'
        assetName = fruitPart.isLeft
            ? 'assets/images/watermelon_cut_left.png'
            : 'assets/images/watermelon_cut_right.png';
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

  Widget _getWatermelon(Fruit fruit) {
    return Image.asset(
      'assets/images/watermelon_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBanana(Fruit fruit) {
    return Image.asset(
      'assets/images/banana_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getApple(Fruit fruit) {
    return Image.asset(
      'assets/images/apple_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getAvocado(Fruit fruit) {
    return Image.asset(
      'assets/images/avocado_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBroccoli(Fruit fruit) {
    return Image.asset(
      'assets/images/broccoli_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getPinkSalmon(Fruit fruit) {
    return Image.asset(
      'assets/images/pink_salmon_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getChicken(Fruit fruit) {
    return Image.asset(
      'assets/images/chicken_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBeef(Fruit fruit) {
    return Image.asset(
      'assets/images/beef_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getArugula(Fruit fruit) {
    return Image.asset(
      'assets/images/arugula_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBread(Fruit fruit) {
    return Image.asset(
      'assets/images/bread_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getEgg(Fruit fruit) {
    return Image.asset(
      'assets/images/egg_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getCorn(Fruit fruit) {
    return Image.asset(
      'assets/images/corn_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getBeer(Fruit fruit) {
    return Image.asset(
      'assets/images/beer_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getVodka(Fruit fruit) {
    return Image.asset(
      'assets/images/vodka_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getCoffee(Fruit fruit) {
    return Image.asset(
      'assets/images/coffee_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getNoodles(Fruit fruit) {
    return Image.asset(
      'assets/images/noodles_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getRice(Fruit fruit) {
    return Image.asset(
      'assets/images/rice_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getMilk(Fruit fruit) {
    return Image.asset(
      'assets/images/milk_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getYogurt(Fruit fruit) {
    return Image.asset(
      'assets/images/yogurt_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getTofu(Fruit fruit) {
    return Image.asset(
      'assets/images/tofu_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getMuffin(Fruit fruit) {
    return Image.asset(
      'assets/images/muffin_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getCornOil(Fruit fruit) {
    return Image.asset(
      'assets/images/corn_oil_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getMango(Fruit fruit) {
    return Image.asset(
      'assets/images/mango_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getCilantro(Fruit fruit) {
    return Image.asset(
      'assets/images/cilantro_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getSugar(Fruit fruit) {
    return Image.asset(
      'assets/images/sugar_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getSoyMilk(Fruit fruit) {
    return Image.asset(
      'assets/images/soy_milk_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getCarrot(Fruit fruit) {
    return Image.asset(
      'assets/images/carrot_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getPumpkin(Fruit fruit) {
    return Image.asset(
      'assets/images/pumpkin_uncut.png',
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _getPotato(Fruit fruit) {
    return Image.asset(
      'assets/images/potato_uncut.png',
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
          } else if (fruit.name == 'broccoli') {
            _broccoliCut++;
          } else if (fruit.name == 'pink salmon') {
            _pinkSalmonCut++;
          } else if (fruit.name == 'chicken') {
            _chickenCut++;
          } else if (fruit.name == 'beef') {
            _beefCut++;
          } else if (fruit.name == 'arugula') {
            _arugulaCut++;
          } else if (fruit.name == 'bread') {
            _breadCut++;
          } else if (fruit.name == 'egg') {
            _eggCut++;
          } else if (fruit.name == 'corn') {
            _cornCut++;
          } else if (fruit.name == 'beer') {
            _beerCut++;
          } else if (fruit.name == 'vodka') {
            _vodkaCut++;
          } else if (fruit.name == 'coffee') {
            _coffeeCut++;
          } else if (fruit.name == 'noodles') {
            _noodlesCut++;
          } else if (fruit.name == 'rice') {
            _riceCut++;
          } else if (fruit.name == 'milk') {
            _milkCut++;
          } else if (fruit.name == 'yogurt') {
            _yogurtCut++;
          } else if (fruit.name == 'tofu') {
            _tofuCut++;
          } else if (fruit.name == 'muffin') {
            _muffinCut++;
          } else if (fruit.name == 'corn oil') {
            _cornOilCut++;
          } else if (fruit.name == 'mango') {
            _mangoCut++;
          } else if (fruit.name == 'cilantro') {
            _cilantroCut++;
          } else if (fruit.name == 'sugar') {
            _sugarCut++;
          } else if (fruit.name == 'soy milk') {
            _soyMilkCut++;
          } else if (fruit.name == 'carrot') {
            _carrotCut++;
          } else if (fruit.name == 'pumpkin') {
            _pumpkinCut++;
          } else if (fruit.name == 'potato') {
            _potatoCut++;
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

  void _checkPlayerHealth(int currentTimeEpoch) async {
    final diseases = await _getNutrientRelatedDiseases();
    if (diseases.isNotEmpty) {
      _endGame(diseases);
    }
  }

  // This method returns a list of diseases based on the player's nutrient levels.
  Future<List<String>> _getNutrientRelatedDiseases() async {
    List<String> diseases = [];
    final upper = await DBInitializer().queryFoodNutritionByName('upper');
    final lower = await DBInitializer().queryFoodNutritionByName('lower');
    int dayPerYear = 365, hundredGramEach = 6;
    double upperScalar = 1.1, lowerScalar = 0.75;
    if (player.water >
        upper[0]['WATER'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hyponatremia");
    if (player.energy >
        upper[0]['ENERGY'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Obesity");
    if (player.protein >
        upper[0]['PROTEIN'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Aminoaciduria");
    if (player.fat >
        upper[0]['FAT'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Heart diseases");
    if (player.carb >
        upper[0]['CARB'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Diabetes");
    if (player.fiber >
        upper[0]['FIBER'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Bowel obstruction");
    if (player.sugar >
        upper[0]['SUGAR'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Diabetes");
    if (player.calcium >
        upper[0]['CALCIUM'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hypercalcemia");
    if (player.iron >
        upper[0]['IRON'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hemochromatosis");
    if (player.magnesium >
        upper[0]['MAGNESIUM'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hypermagnesemia");
    if (player.phosphorus >
        upper[0]['PHOSPHORUS'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hyperphosphatemia");
    if (player.potassium >
        upper[0]['POTASSIUM'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hyperkalemia");
    if (player.sodium >
        upper[0]['SODIUM'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hypernatremia");
    if (player.zinc >
        upper[0]['ZINC'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Zinc toxicity");
    if (player.copper >
        upper[0]['COPPER'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Wilson’s disease");
    if (player.manganese >
        upper[0]['MANGANESE'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Manganese toxicity");
    if (player.selenium >
        upper[0]['SELENIUM'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Selenosis");
    if (player.vc > upper[0]['VC'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Diarrhea");
    if (player.vb > upper[0]['VB'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("");
    if (player.va > upper[0]['VA'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hypervitaminosis A");
    if (player.vd > upper[0]['VD'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Hypervitaminosis D");
    if (player.vk > upper[0]['VK'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Vitamin K excess");
    if (player.caffeine >
        upper[0]['CAFFEINE'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Anxiety & insomnia");
    if (player.alcohol >
        upper[0]['ALCOHOL'] * dayPerYear * hundredGramEach * upperScalar)
      diseases.add("Alcohol disorder");
    if (player.water >
        lower[0]['WATER'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Dehydration");
    if (player.energy >
        lower[0]['ENERGY'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Energy deficiency");
    if (player.protein >
        lower[0]['PROTEIN'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Kwashiorkor");
    if (player.fat >
        lower[0]['FAT'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Essential fatty acids deficiency");
    if (player.carb >
        lower[0]['CARB'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Energy deficiencyd");
    if (player.fiber >
        lower[0]['FIBER'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Constipation, digestive issues");
    if (player.sugar >
        lower[0]['SUGAR'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Lack of sugar");
    if (player.calcium >
        lower[0]['CALCIUM'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Osteoporosis");
    if (player.iron >
        lower[0]['IRON'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Anemia");
    if (player.magnesium >
        lower[0]['MAGNESIUM'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Muscle cramps");
    if (player.phosphorus >
        lower[0]['PHOSPHORUS'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Weak bones");
    if (player.potassium >
        lower[0]['POTASSIUM'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Hypokalemia");
    if (player.sodium >
        lower[0]['SODIUM'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Hyponatremia");
    if (player.zinc >
        lower[0]['ZINC'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Growth retardation");
    if (player.copper >
        lower[0]['COPPER'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("cardiovascular diseases");
    if (player.manganese >
        lower[0]['MANGANESE'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Bone malformation");
    if (player.selenium >
        lower[0]['SELENIUM'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Keshan disease");
    if (player.vc > lower[0]['VC'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Scurvy");
    if (player.vb > lower[0]['VB'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Various deficiency diseases");
    if (player.va > lower[0]['VA'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Night blindness");
    if (player.vd > lower[0]['VD'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Rickets");
    if (player.vk > lower[0]['VK'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Bleeding disorders");
    if (player.caffeine >
        lower[0]['CAFFEINE'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Sleep disorders");
    if (player.alcohol >
        lower[0]['ALCOHOL'] * dayPerYear * hundredGramEach * lowerScalar)
      diseases.add("Alcohol withdrawal syndrome");

    return diseases;
  }
}
