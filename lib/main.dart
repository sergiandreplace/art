import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Isometric"),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Isometric(),
      ),
    );
  }
}

class Isometric extends StatefulWidget {
  @override
  _IsometricState createState() => _IsometricState();
}

class _IsometricState extends State<Isometric> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  double time = 0;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    animationController.duration = Duration(seconds: 5);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) animationController.forward(from: 0);
    });
    animationController.forward(from: 0);
    animationController.addListener(() => setState(() => time = animationController.value));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IsometricPainter(time),
    );
  }
}

class IsometricPainter extends CustomPainter {
  final List<List<int>> grid = [
    [1, 2, 3],
    [1, 2, 3],
    [1, 2, 3]
  ];
  final Paint plain = Paint()
    ..color = Color(0xFF7FADA9)
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  final Paint plainBase = Paint()
    ..color = Color(0xFF7FADA9)
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  final Paint backgroundPaint = Paint()
    ..color = Color(0x44F6EDD3)
    ..isAntiAlias = false;
  final Paint clear = Paint()
    ..color = Color(0xFFCCD9CE)
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  final Paint dark = Paint()
    ..color = Color(0xFF588E95)
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  double time = 0;
  IsometricPainter(this.time);

  @override
  void paint(Canvas canvas, Size size) {
    var gridSize = 24; //grid.length;
    var maxHeight = 30;
    var minSize = min(size.width, size.height);
    var tileHeight = (minSize / (gridSize + maxHeight)) * 0.95;
    var tileWidth = tileHeight * 2;
    var tileSize = Size(tileWidth, tileHeight);
    var start = Offset(size.width / 2, (size.height + tileHeight * maxHeight - tileSize.height * gridSize) / 2);

    void drawBackground() {
      Path path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(start.dx + gridSize * tileSize.width / 2, start.dy + gridSize * tileSize.height / 2);
      path.lineTo(start.dx, start.dy + gridSize * tileSize.height);
      path.lineTo(start.dx - gridSize * tileSize.width / 2, start.dy + gridSize * tileSize.height / 2);
      path.close();
      canvas.drawPath(path, dark);
    }

    void drawTile(double x, double y, {double light}) {
      var tileStart = Offset(
        start.dx + tileSize.width * x / 2 - tileSize.width * y / 2,
        start.dy + tileSize.height * x / 2 + tileSize.height * y / 2,
      );
      Path path = Path();
      path.moveTo(tileStart.dx, tileStart.dy);
      path.lineTo(tileStart.dx + tileSize.width / 2, tileStart.dy + tileSize.height / 2);
      path.lineTo(tileStart.dx, tileStart.dy + tileSize.height);
      path.lineTo(tileStart.dx - tileSize.width / 2, tileStart.dy + tileSize.height / 2);
      path.close();

      if (light != null) {
        var l = min(0.70, max(light.abs(), 0.41));
        plain.color = HSLColor.fromColor(plainBase.color).withLightness(l).toColor();
      } else {
        plain.color = plainBase.color;
      }
      canvas.drawPath(path, plain);
    }

    void drawBlock(double x, double y, double height) {
      var tileFloor = Offset(
        start.dx + tileSize.width * x / 2 - tileSize.width * y / 2,
        start.dy + tileSize.height * x / 2 + tileSize.height * y / 2,
      );
      var tileTop = Offset(
        start.dx + tileSize.width * (x - height) / 2 - tileSize.width * (y - height) / 2,
        start.dy + tileSize.height * (x - height) / 2 + tileSize.height * (y - height) / 2,
      );

      Path leftSide = Path();
      leftSide.moveTo(tileTop.dx - tileSize.width / 2, tileTop.dy + tileSize.height / 2);
      leftSide.lineTo(tileTop.dx, tileTop.dy + tileSize.height);
      leftSide.lineTo(tileFloor.dx, tileFloor.dy + tileSize.height);
      leftSide.lineTo(tileFloor.dx - tileSize.width / 2, tileFloor.dy + tileSize.height / 2);
      leftSide.close();
      canvas.drawPath(leftSide, clear);

      Path rightSide = Path();
      rightSide.moveTo(tileTop.dx + tileSize.width / 2, tileTop.dy + tileSize.height / 2);
      rightSide.lineTo(tileTop.dx, tileTop.dy + tileSize.height);
      rightSide.lineTo(tileFloor.dx, tileFloor.dy + tileSize.height);
      rightSide.lineTo(tileFloor.dx + tileSize.width / 2, tileFloor.dy + tileSize.height / 2);
      rightSide.close();
      canvas.drawPath(rightSide, dark);
      drawTile(
        x - height,
        y - height,
        light: height.toDouble() / maxHeight.toDouble(),
      );
    }

    canvas.drawPaint(backgroundPaint);
    drawBackground();
    for (double i = 0; i < gridSize; i++) {
      for (double j = 0; j < gridSize; j++) {
        drawTile(i, j);
        var id = pi * 2 * time + pi * i / gridSize;
        var ij = pi * 2 * time + pi * j / gridSize;
        drawBlock(i, j, ((maxHeight / 2) + sin(id) * cos(ij) * maxHeight / 2));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
