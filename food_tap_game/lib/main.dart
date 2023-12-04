import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition Game',
      home: GameHomePage(),
    );
  }
}

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage> {
  static const maxTime = 120;
  int currentTime = maxTime;
  Timer? countdownTimer;
  double get progress => currentTime / maxTime;

  // @override
  // void initState() {
  //   super.initState();
  //   startTimer();
  // }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    setState(() {
      if (currentTime > 0) {
        currentTime--;
      } else {
        countdownTimer!.cancel();
        // Handle game over logic here
      }
    });
  }

  // @override
  // void dispose() {
  //   countdownTimer?.cancel();
  //   super.dispose();
  // }



  ///////////////////////////////////
  List<String> foods = ["Cilantro", "Banana", "Apple", 'Orange']; // Add more food items here
  Map<String, Offset> foodPositions = {};



  ///////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nutrition Game')),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          ...foodPositions.keys.map((food) => _buildMovingFoodText(food)).toList(),
          // Add other game elements here
        ],
      ),
    );
  }


  Widget _buildMovingFoodText(String food) {
    return AnimatedPositioned(
      duration: Duration(seconds: Random().nextInt(5) + 3), // Random duration for movement
      curve: Curves.linear,
      top: foodPositions[food]!.dy,
      left: foodPositions[food]!.dx,
      child: GestureDetector(
        onTap: () => _handleFoodTap(food),
        child: Text(food),
      ),
    );
  }

  void _handleFoodTap(String food) {
    setState(() {
      // Remove the food text
      foodPositions.remove(food);
    });
  }


  @override
  void initState() {
    super.initState();
    startTimer();

    // Schedule the generation of food positions after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRandomFoodPositions();
    });
  }


  void _generateRandomFoodPositions() {
    for (var food in foods) {
      foodPositions[food] = Offset(
        Random().nextDouble() * MediaQuery.of(context).size.width,
        Random().nextDouble() * MediaQuery.of(context).size.height,
      );
    }
  }


  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

}





























