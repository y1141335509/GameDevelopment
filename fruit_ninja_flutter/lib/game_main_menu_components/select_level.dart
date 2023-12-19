import 'package:flutter/material.dart';

import './levels/level_01.dart';
import './levels/level_02.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key})
      : super(key: key); // Marked as nullable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Level')),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Level 1'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CanvasAreaLevel_01(level: 1)));
            },
          ),
          ListTile(
            title: Text('Level 2'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CanvasAreaLevel_02(level: 2)));
            },
          ),
          // Add more levels as needed
        ],
      ),
    );
  }
}
