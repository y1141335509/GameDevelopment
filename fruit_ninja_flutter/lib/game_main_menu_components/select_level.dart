import 'package:flutter/material.dart';

import './levels/level_00.dart';
import './levels/level_01.dart';
import './levels/level_02.dart';
import './levels/level_03.dart';
import './levels/level_04.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> levels = [
      CanvasAreaLevel_00(level: 0),
      CanvasAreaLevel_01(level: 1),
      CanvasAreaLevel_02(level: 2),
      CanvasAreaLevel_03(level: 3),
      CanvasAreaLevel_04(level: 4),
      // Add more levels as needed
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Select Level')),
      body: GridView.builder(
        itemCount: levels.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 每行个数
          mainAxisSpacing: 10.0, // 行间距
          crossAxisSpacing: 10.0, // 列间距
        ),
        itemBuilder: (BuildContext context, int index) {
          return ElevatedCard(
            level: index,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => levels[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final int level;
  final VoidCallback onTap;

  const ElevatedCard({Key? key, required this.level, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            'Level $level',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
