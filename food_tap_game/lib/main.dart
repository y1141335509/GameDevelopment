import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft])
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

class _GameHomePageState extends State<GameHomePage>
    with TickerProviderStateMixin {
  static const maxTime = 120;
  int currentTime = maxTime;
  Timer? countdownTimer;
  double get progress => currentTime / maxTime;
  late AnimationController progressController;
  bool isGamePaused = false;


  List<String> foods = [
    "Cilantro",
    "Banana",
    "Apple",
    'Orange',
    'Hello'
  ]; // Add more food items here
  Map<String, Offset> foodPositions = {};
  Map<String, Offset> foodMovements = {};

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    setState(() {
      if (currentTime > 0) {
        currentTime--;
      } else {
        countdownTimer!.cancel();
        foodGenerationTimer?.cancel();
        // Handle game over logic here
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your time is up!!'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context)
                  .pop(); // Optionally, navigate back to a previous screen
            },
          )
        ],
      ),
    );
  }

  ///////////////////////////////////
  void togglePauseResumeGame() {
    if (isGamePaused) {
      // Resume the game
      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
      foodGenerationTimer?.cancel();
      foodGenerationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (currentTime > 0) {
          _generateRandomFoodPositionAndMovement();
        } else {
          timer.cancel();
        }
      });
      progressController.forward(from: progressController.value);
    } else {
      // Pause the game
      countdownTimer?.cancel();
      foodGenerationTimer?.cancel();
      progressController.stop();
    }
    setState(() {
      isGamePaused = !isGamePaused;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Nutrition Game')),
    body: Stack(
      children: <Widget>[
        ...foodPositions.keys.map((food) => _buildMovingFoodText(food)).toList(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: progressController.value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 10), // Spacing between progress bar and button
              ElevatedButton(
                onPressed: togglePauseResumeGame,
                child: Text(isGamePaused ? 'Resume' : 'Pause'),
              ),
            ],
          ),
        ),
        // Add other game elements here
      ],
    ),
  );
}




  void _handleFoodTap(String food) {
    setState(() {
      // Remove the food text
      foodPositions.remove(food);
    });
  }

  //////////////
  Timer? foodGenerationTimer;
  //////////////

  int foodCounter = 0; // a counter to generate unique identifiers for each food
  @override
  void initState() {
    super.initState();
    startTimer();

    // Initialize the progress controller
    progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: maxTime),
    )..addListener(() {
        setState(() {});
      });
    progressController.forward();

    // Start a timer to generate new food texts continuously
    foodGenerationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (currentTime > 0) {
        _generateRandomFoodPositionAndMovement();
      } else {
        timer.cancel();
      }
    });
  }

  void _generateRandomFoodPositionAndMovement() {
    final random = Random();
    final foodIndex = random.nextInt(foods.length);
    final food = "${foods[foodIndex]}_${foodCounter++}";

    final startPosition = Offset(
      random.nextDouble() * MediaQuery.of(context).size.width,
      random.nextDouble() * MediaQuery.of(context).size.height,
    );

    final targetPosition = Offset(
      random.nextDouble() * MediaQuery.of(context).size.width,
      random.nextDouble() * MediaQuery.of(context).size.height,
    );

    setState(() {
      foodPositions[food] = startPosition;
      foodMovements[food] = targetPosition;
    });

    // Start a timer for each food text to update its position continuously
    Timer.periodic(Duration(seconds: random.nextInt(5) + 3), (timer) {
      if (!foodPositions.containsKey(food)) {
        timer.cancel();
      } else {
        setState(() {
          foodPositions[food] = foodMovements[food]!;
          // Update target position for the next movement
          foodMovements[food] = Offset(
            random.nextDouble() * MediaQuery.of(context).size.width,
            random.nextDouble() * MediaQuery.of(context).size.height,
          );
        });
      }
    });
  }

  Widget _buildMovingFoodText(String food) {
    return AnimatedPositioned(
      duration: Duration(seconds: 3), // Duration of movement
      curve: Curves.linear,
      top: foodPositions[food]!.dy,
      left: foodPositions[food]!.dx,
      child: GestureDetector(
        onTap: () => _handleFoodTap(food),
        child: Text(food.split('_')[0]),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    foodGenerationTimer?.cancel();
    progressController.dispose();
    super.dispose();
  }
}
