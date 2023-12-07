import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/fruit.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'slice_painter.dart';

List<String> fruitNames = ['melon', 'apple', 'banana'];

// fruitsCut defines the number of each fruit type is cut after game play.
Map<String, int> fruitsCut = {'melon': 0, 'apple': 0, 'banana': 0};

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

    // Start the countdown
    _countdownController.reverse(from: 1.0);

    // add status listener:
    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        // if run times up, then quit the game
        // SystemNavigator.pop();
        // Navigator.of(context).pop(); // Navigate back to game menu after 120s
      }
    });

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
    setState(() {
      for (Fruit fruit in _fruits) {
        fruit.applyGravity();
      }
      for (FruitPart fruitPart in _fruitParts) {
        fruitPart.applyGravity();
      }

      // check survival at key time points (20 seconds per each)
      _checkSurvival();

      if (Random().nextDouble() > 0.97) {
        _spawnRandomFruit();
      }
    });

    Future<void>.delayed(Duration(milliseconds: 30), _tick);
  }

  void _checkSurvival() {
    int currentTime = (120 -
            (_countdownController.duration?.inSeconds ?? 0) *
                _countdownController.value)
        .round();

    // check if dead every 20 seconds
    if (fruitMinMax.containsKey(currentTime)) {
      List<dynamic> thresholds = fruitMinMax[currentTime] ?? [0, 0];

      // reasons for dying:
      // abnormally high blood sugar level
      // hyperkalemia
      // Gastrointestinal Diseases
      if (_melonsCut < thresholds[0]) {
        _endGame("You died due to abnormally low blood sugar level");
      } else if (_melonsCut > thresholds[1]) {
        _endGame("You died due to abnormally high blood sugar level");
      } else if (_bananaCut < thresholds[0]) {
        _endGame("You died due to abnormally low potassium level");
      } else if (_bananaCut > thresholds[1]) {
        _endGame("You died due to abnormally high potassium level");
      } else if (_appleCut < thresholds[0]) {
        _endGame("You died due to Gastrointestinal Diseases");
      } else if (_appleCut > thresholds[1]) {
        _endGame("You died due to Gastrointestinal Diseases");
      }
    } else if (currentTime >= 120) {
      _endGame("Congrats!");
    }
  }

  void _pauseGame() {
    setState(() {
      _isGamePaused = !_isGamePaused;
      if (_isGamePaused) {
        _countdownController.stop(); // Stop the countdown timer
        // Implement any other pausing logic here
      } else {
        _countdownController.forward(); // Resume the countdown timer
        // Implement any resume logic here
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
    return Stack(children: _getStack());
  }

  List<Widget> _getStack() {
    List<Widget> widgetsOnStack = <Widget>[];

    widgetsOnStack.add(_getBackground());
    widgetsOnStack.add(_getSlice());
    widgetsOnStack.addAll(_getFruitParts());
    widgetsOnStack.addAll(_getFruits());
    widgetsOnStack.add(_getGestureDetector());
    widgetsOnStack.add(
      Positioned(
        right: 200,
        top: 16,
        child: Text(
          'Score: $_score',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );

    // add progress bar to the canvas area
    widgetsOnStack.add(
      Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: Row(
          children: [
            // Wrap the progress bar with a SizedBox or Container
            SizedBox(
              width: 400, // Set the width as per your requirement
              child: LinearProgressIndicator(
                value: _countdownController.value,
                backgroundColor: Colors.grey[150],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            SizedBox(width: 10),
            Text(countdownText, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );

    // Add Exit button
    widgetsOnStack.add(
      Positioned(
        top: 16,
        right: 16,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the game menu
          },
          child: Text("Exit"),
        ),
      ),
    );

    // add Pause Game button:
    widgetsOnStack.add(Positioned(
        top: 16,
        right: 72,
        child: ElevatedButton(
          onPressed: () => _pauseGame(),
          child: Text(_isGamePaused ? "Resume" : "Pause"),
        )));

    return widgetsOnStack;
  }

  Container _getBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          stops: <double>[0.2, 1.0],
          colors: <Color>[Color(0xffFFB75E), Color(0xffED8F03)],
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

          // handle fruit cut:
          if (fruit.name == 'melon') {
            _melonsCut++;
          } else if (fruit.name == 'banana') {
            _bananaCut++;
          } else if (fruit.name == 'apple') {
            _appleCut++;
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

  void _setNewSlice(details) {
    _touchSlice = TouchSlice(pointsList: <Offset>[details.localFocalPoint]);
  }

  void _addPointToSlice(ScaleUpdateDetails details) {
    if (_touchSlice?.pointsList == null || _touchSlice!.pointsList.isEmpty) {
      return;
    }

    if (_touchSlice!.pointsList.length > 16) {
      _touchSlice!.pointsList.removeAt(0);
    }
    _touchSlice!.pointsList.add(details.localFocalPoint);
  }
}
