import 'dart:math';

import 'package:flutter/material.dart';

const Color DEFAULT_BASE_COLOR = Color(0xFFD9D9D9);
const Color DEFAULT_DARK_SIDE_COLOR = Color(0xFFBFBFBF);
const Color DEFAULT_LIGHT_SIDE_COLOR = Color(0xFFF2F2F2);
const double DEFAULT_MAX_HEIGHT = 30;

class Isometric extends StatelessWidget {
  final List<List<double>> grid;
  final Color baseColor;
  final Color darkSideColor;
  final Color lightSideColor;
  final double maxHeight;

  Isometric(this.grid,
      {this.baseColor = DEFAULT_BASE_COLOR,
      this.darkSideColor = DEFAULT_DARK_SIDE_COLOR,
      this.lightSideColor = DEFAULT_LIGHT_SIDE_COLOR,
      this.maxHeight = DEFAULT_MAX_HEIGHT}) {
    grid.forEach((element) {
      assert(element.length == grid.length, "grid should be a square");
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: IsometricPainter(this),
    );
  }
}

class IsometricPainter extends CustomPainter {
  final Paint basePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  final Paint lightSide = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;
  final Paint darkSide = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;

  final Isometric widget;

  IsometricPainter(this.widget);

  @override
  void paint(Canvas canvas, Size size) {
    var grid = widget.grid;
    basePaint.color = widget.baseColor;
    darkSide.color = widget.darkSideColor;
    lightSide.color = widget.lightSideColor;
    var baseHslColor = HSLColor.fromColor(widget.baseColor);
    int gridSize = grid.length;

    var maxHeight = widget.maxHeight;
    double padding = 0.95;
    double vw = gridSize.toDouble();
    double vh = (gridSize + maxHeight) / 2;
    double sw = size.width * padding;
    double sh = size.height * padding;

    var tileWidth = vw / vh < sw / sh ? sh / vh : sw / vw;
    var tileHeight = tileWidth / 2;

    var tileSize = Size(tileWidth, tileHeight);
    var startX = size.width / 2;
    var startY = maxHeight * tileHeight + size.height / 2 - tileHeight * (gridSize + maxHeight) / 2;
    var start = Offset(startX, startY);

    Gradient lightGradient = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [widget.baseColor, widget.lightSideColor],
    );
    Gradient darkGradient = LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [widget.darkSideColor, widget.baseColor],
    );

    void drawBackground() {
      Path path = Path();
      path.moveTo(start.dx, start.dy);
      path.lineTo(start.dx + gridSize * tileSize.width / 2, start.dy + gridSize * tileSize.height / 2);
      path.lineTo(start.dx, start.dy + gridSize * tileSize.height);
      path.lineTo(start.dx - gridSize * tileSize.width / 2, start.dy + gridSize * tileSize.height / 2);
      path.close();
      canvas.drawPath(path, basePaint);
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
        var l = min(0.90, max(baseHslColor.lightness - (0.5 - light) / 36, 0.1));
        basePaint.color = baseHslColor.withLightness(l).toColor();
      } else {
        basePaint.color = widget.baseColor;
      }
      canvas.drawPath(path, basePaint);
    }

    void drawBlock(int x, int y, double height) {
      if (height == 0) {
        drawTile(x.toDouble(), y.toDouble(), light: 0);
        return;
      }
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
      lightSide.shader = lightGradient.createShader(
        Rect.fromLTRB(
          tileTop.dx - tileSize.width / 2,
          tileTop.dy + tileSize.height / 2,
          tileFloor.dx,
          tileFloor.dy + tileSize.height,
        ),
      );
      canvas.drawPath(leftSide, lightSide);

      Path rightSide = Path();
      rightSide.moveTo(tileTop.dx + tileSize.width / 2, tileTop.dy + tileSize.height / 2);
      rightSide.lineTo(tileTop.dx, tileTop.dy + tileSize.height);
      rightSide.lineTo(tileFloor.dx, tileFloor.dy + tileSize.height);
      rightSide.lineTo(tileFloor.dx + tileSize.width / 2, tileFloor.dy + tileSize.height / 2);
      rightSide.close();
      darkSide.shader = darkGradient.createShader(
        Rect.fromLTRB(
          tileTop.dx - tileSize.width / 2,
          tileTop.dy + tileSize.height / 2,
          tileFloor.dx,
          tileFloor.dy + tileSize.height,
        ),
      );
      canvas.drawPath(rightSide, darkSide);
      drawTile(
        x - height,
        y - height,
        light: height.toDouble() / maxHeight.toDouble(),
      );
    }

    // drawBackground();
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        if (grid[i][j] != null) {
          drawBlock(i, j, grid[i][j]);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
