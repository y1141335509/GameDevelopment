import 'package:flutter/material.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '迷宫游戏',
      home: CanvasAreaLevel_03(level: 3),
    );
  }
}

class CanvasAreaLevel_03 extends StatefulWidget {
  final int level;

  const CanvasAreaLevel_03({Key? key, required this.level})
      : super(key: key); // Added required for level

  @override
  _MazeGameState createState() => _MazeGameState();
}

class _MazeGameState extends State<CanvasAreaLevel_03> {
  Offset playerPosition = Offset(100, 100); // 示例玩家位置

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('迷宫游戏'),
      ),
      body: Center(
        child: CustomPaint(
          painter: MazeGamePainter(playerPosition),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class MazeGamePainter extends CustomPainter {
  final Offset playerPosition;

  MazeGamePainter(this.playerPosition);

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制迷宫、玩家和食物等（此处省略）

    // 绘制黑色幕布，只显示玩家附近区域
    var paint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(playerPosition, 50, paint); // 以玩家为中心的可视区域
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}




