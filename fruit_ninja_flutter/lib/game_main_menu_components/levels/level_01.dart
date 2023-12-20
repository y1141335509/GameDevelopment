import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flame_audio/flame_audio.dart';
import 'package:collection/collection.dart';

import 'models/fruit.dart';
import './player.dart';
import 'models/fruit_part.dart';
import 'models/touch_slice.dart';
import 'slice_painter.dart';
import '../../db_initializer.dart';
import './db_helper_levels/db_helper_level_01.dart';

Future<List<String>> names = DBInitializer().queryAllFoodNames();

final int gameDuration = 30; // 游戏时长

late Player player; // Instance to hold player's state

class CanvasAreaLevel_01 extends StatefulWidget {
  final int level;

  const CanvasAreaLevel_01({Key? key, required this.level})
      : super(key: key); // Added required for level

  @override
  _CanvasAreaState createState() => _CanvasAreaState();
}

class _CanvasAreaState extends State<CanvasAreaLevel_01>
    with TickerProviderStateMixin {
  int _score = 0;
  int _highScore = 0; // 当前玩家的历史最高分
  TouchSlice? _touchSlice;

  final List<Fruit> _fruits = <Fruit>[]; // 要生成的食物

  final List<FruitPart> _fruitParts = <FruitPart>[]; // 要生成的食物的切片

  // 倒计时；同时也可以用来计算游戏开始了多少时间
  late AnimationController _countdownController;
  bool _isGamePaused = false;

  Map<String, int> foodSpawnConfig = {
    'watermelon': 0,
    'apple': 0,
    'banana': 1,
    'avocado': 0,
    'broccoli': 2,
    'pink_salmon': 0,
    'chicken': 1,
    'beef': 2,
    'arugula': 2,
    'bread': 0,
    'egg': 9,
    'corn': 2,
    'beer': 1,
    'vodka': 0,
    'coffee': 1,
    'noodles': 0,
    'rice': 1,
    'milk': 0,
    'yogurt': 0,
    'tofu': 2,
    'muffin': 3,
    'corn_oil': 4,
    'mango': 0,
    'cilantro': 0,
    'sugar': 0,
    'soy_milk': 0,
    'carrot': 16,
    'pumpkin': 0,
    'potato': 0,
  };

  final int totalFoodCount = 47; // 计算所有食物一共有多少个
  int remainingFoodCount = 47; // 还剩下多少食物需要生成

  @override
  void initState() {
    super.initState();

    // 加载当前玩家的历史最高分：
    _getHighScore();

    // Initialize the countdown controller
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..addListener(() {
        setState(() {});
      });

    // Add status listener
    _countdownController.addStatusListener((status) async {
      if (status == AnimationStatus.dismissed) {
        final diseases = await _getNutrientRelatedDiseases();
        _endGame(diseases);
      }
    });
    _countdownController.reverse(from: 1.0);

    // Initialize the player with default nutritional values
    player = Player(id: 0);

    // _spawnSingleFood()里面使用了MediaQuery，使用它的前提是
    // initState已经被call。所以要加上这个if(mounted)来确保
    // Future.delayed(Duration.zero, () {
    //   if (mounted) {
    //     _spawnRandomFood();
    //   }
    // });

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


  void _spawnRandomFood() {
    int elapsedTime = (gameDuration -
            (_countdownController.duration?.inSeconds ?? 0) *
                _countdownController.value)
        .round(); // 游戏开始了多长时间

    // 如果还有剩余游戏时长
    if (elapsedTime <= gameDuration) {
      // 如果没有食物需要生成 或者游戏被暂停 则停止生成食物
      if (_isGamePaused || foodSpawnConfig.isEmpty || remainingFoodCount <= 0) {
        return;
      } else {
        // 生成随机食物名
        Random random = Random();
        List<String> foodNames = foodSpawnConfig.keys.toList();
        String randomFoodName = foodNames[random.nextInt(foodNames.length)];
        while (foodSpawnConfig[randomFoodName] == 0) {
          // 弹出已经是 0 的 食物，节省时间
          foodSpawnConfig.removeWhere((key, value) => value == 0);
          randomFoodName = foodNames[random.nextInt(foodNames.length)];
        }

        // 生成当前随机到的食物
        _spawnSingleFood(randomFoodName);
        remainingFoodCount--;
        print('remaining food count: ' + remainingFoodCount.toString());
      }
    }
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
    if (!_isGamePaused && mounted) {
      setState(() {
        // 为每个食物添加重力
        for (Fruit fruit in _fruits) {
          fruit.applyGravity();
        }
        // 为每个被切开的食物添加重力
        for (FruitPart fruitPart in _fruitParts) {
          fruitPart.applyGravity();
        }

        // 0.97意味着，每次调用_tick()方法时，调用_spawnRandomFood()的概率是 1 - 0.97
        if (Random().nextDouble() > 0.94) {
          // 假设_spawnRandomFood()每秒生成一个食物，那么生成食物的频率就是：
          // (1 - 0.97) * (1000 / 30) ~= 1.00次/秒
          _spawnRandomFood();
        }
      });

      int currentTime = (gameDuration -
              (_countdownController.duration?.inSeconds ?? 0) *
                  _countdownController.value)
          .round();

      if (currentTime >= gameDuration) {
        List<String> win = [];
        win.add("Congrats!");
        _endGame(win);
      } else if (currentTime % 2 == 0 && currentTime > 0) {
        _checkPlayerHealth(currentTime);
      }

      // 递归，只要游戏不暂停就一直运行。
      // 其中的Duration控制着_tick()方法被调用的频率，也就是每30毫秒1次
      // 所以每秒调用_tick()方法的次数为： 1000毫秒每秒 / (30毫秒每次) = 33.33次/秒
      // 更通俗的理解，这里的33.33次/秒 就是“帧率”。
      // 但要注意，该游戏中这里的30并不是通俗意义上的 帧率，而是 游戏速度
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

    // 确保showDialog()能获得它所将要使用的信息：
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 确保被initState() mount上
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
    });
    _saveHighScore(_score); // 保存当前关卡的最高分
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    String highScoreKey = 'highScore_level_${widget.level}'; // 每个关卡的唯一键
    int currentHighScore = prefs.getInt(highScoreKey) ?? 0;

    if (score > currentHighScore) {
      await prefs.setInt(highScoreKey, score);
    }
  }

  void _getHighScore() async {
    ////////////////////// TESTING ///////////////////////////
    // 加载数据库：
    Database db = await DBHelperLevel_01.initializeDB(); // 数据库初始化函数
    await DBHelperLevel_01.importCSVToSQLite(db); // 导入CSV数据到SQLite

    List<Map<dynamic, dynamic>> counts = await DBHelperLevel_01().queryAll();
    counts.forEach((element) {
      print('debugging...' + element.values.toString());
      print('debugging...' + element.keys.toString());
    });
    ////////////////////// TESTING ///////////////////////////


    // 获取该用户的历史最高分
    final prefs = await SharedPreferences.getInstance();
    String highScoreKey = 'highScore_level_${widget.level}'; // 每个关卡的唯一键
    setState(() {
      _highScore = prefs.getInt(highScoreKey) ?? 0;
    });
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
    widgetsOnStack.addAll(_getFruitParts()); // 将所有食物切片添加到Widget上显示
    widgetsOnStack.addAll(_getFruits()); // 将所有食物添加到Widget上显示
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

    // 添加最高分：
    widgetsOnStack.add(
      Positioned(
        top: screenHeight * 0.1, // 2% of screen height from the top
        right: screenWidth * 0.05, // 5% of screen width from the right

        child: Text(
          'Highest Score: $_highScore',
          style: TextStyle(
            fontSize: scoreFontSize,
            color: Colors.green,
          ), // 根据需要调整字体大小
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
    String imagePath = 'assets/images/' +
        fruit.name.replaceAll(RegExp(' '), '_') +
        '_uncut.png';
    return Image.asset(
      imagePath,
      height: 80,
      fit: BoxFit.fitHeight,
    );
  }

  List<Widget> _getFruitParts() {
    List<Widget> list = <Widget>[];
    for (FruitPart fruitPart in _fruitParts) {
      list.add(
        Positioned(
          top: fruitPart.position.dy,
          left: fruitPart.position.dx,
          child: _getCutFruit(fruitPart),
        ),
      );
    }

    return list;
  }

  Widget _getCutFruit(FruitPart fruitPart) {
    String assetName;
    String fruitName = fruitPart.fruitName.replaceAll(RegExp(' '), '_');
    fruitPart.isLeft
        ? assetName = 'assets/images/' + fruitName + '_cut_left.png'
        : assetName = 'assets/images/' + fruitName + '_cut_right.png';

    return Transform.rotate(
        angle: fruitPart.rotation * pi * 2,
        child: Image.asset(
          assetName,
          height: 80,
          fit: BoxFit.fitHeight,
        ));
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
        // 如果切到了食物
        if (secondPointInside && !fruit.isPointInside(point)) {
          _fruits.remove(fruit);
          _turnFruitIntoParts(fruit);
          _score += 10;

          // update player's nutrition
          _updatePlayerNutrition(fruit.name);

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
    if (nutrition != null && nutrition.isNotEmpty) {
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

// For creating a PriorityQueue
class FoodItem {
  String name;
  int initialCount;
  int remainingCount;

  FoodItem(this.name, this.initialCount) : remainingCount = initialCount;

  void pop() {
    if (remainingCount > 0) {
      remainingCount--;
    }
  }

  bool get isDepleted => remainingCount <= 0;
}
