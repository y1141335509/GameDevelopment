import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreScreen extends StatefulWidget {
  @override
  _HighScoreScreenState createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("High Score"),
      ),
      body: Center(
        child: Text(
          'High Score: $_highScore',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
