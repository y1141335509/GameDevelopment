import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'canvas_area/canvas_area.dart';



class GameMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Menu"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CanvasArea())),
              child: Text("Start"),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement High Score logic here
                // Example: showHighScores(context);
              },
              child: Text("High Score"),
            ),
            ElevatedButton(
              onPressed: () => SystemNavigator.pop(), // This exits the app
              child: Text("Exit Game"),
            ),
          ],
        ),
      ),
    );
  }

  // Example function to show high scores (Implement according to your app logic)
  void showHighScores(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("High Scores"),
          content: Text("High scores go here..."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
