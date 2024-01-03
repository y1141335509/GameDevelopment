import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flame/game.dart';

// import './game_main_menu_components/select_level.dart';
import './game_main_menu_components/select_level_pixel.dart';
import './game_main_menu_components/high_score_page.dart';

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
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameWidget(
                        game: LevelSelectionScreen(
                            viewportResolution: Vector2(1280, 720))),
                  )

                  // MaterialPageRoute(
                  //     builder: (context) => LevelSelectionScreen())

                  ),
              child: Text("Enter Game"),
            ),
            // In your GameMenuScreen class

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HighScoreScreen()),
                );
              },
              child: Text("High Score"),
            ),

            ElevatedButton(
              onPressed: () =>
                  {SystemNavigator.pop(), exit(0)}, // This exits the app
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
