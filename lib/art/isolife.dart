import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../isometric.dart';

class IsometricLife extends StatefulWidget {
  @override
  _IsometricLifeState createState() => _IsometricLifeState();
}

class _IsometricLifeState extends State<IsometricLife> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  List<List<double>> grid = [];
  List<List<double>> drawingGrid = [];
  List<List<double>> previousGrid = [];
  final double maxHeight = 1;
  final int size = 24;

  @override
  void initState() {
    super.initState();
    previousGrid = buildInitialGrid(size);
    grid = evolveGrid(previousGrid);
    animationController = AnimationController(vsync: this);
    animationController.duration = Duration(milliseconds: 200);
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeInOut);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        previousGrid = grid;
        grid = evolveGrid(grid);
        new Timer(Duration(milliseconds: 100), () {
          animationController.forward(from: 0);
        });
      }
    });
    animationController.forward(from: 0);
    animationController.addListener(() {
      setState(() {
        drawingGrid = lerpGrid(animation.value, previousGrid, grid);
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Isometric(
      drawingGrid,
      maxHeight: maxHeight,
      baseColor: Color(0xFFF2CEA2),
      darkSideColor: Color(0xFFD95B72),
      lightSideColor: Color(0xFFF2F1DC),
    );
  }

  List<List<double>> buildInitialGrid(int size) {
    final Random r = Random();
    List<List<double>> grid = [];
    for (int i = 0; i < size; i++) {
      List<double> row = [];
      for (int j = 0; j < size; j++) {
        row.add((r.nextDouble() * 2).floorToDouble());
      }
      grid.add(row);
    }
    return grid;
  }

  List<List<double>> evolveGrid(List<List<double>> grid) {
    List<List<double>> newGrid = [];
    for (int i = 0; i < size; i++) {
      List<double> row = [];
      for (int j = 0; j < size; j++) {
        double energy = getNeighboursCount(grid, i, j);
        bool alive = (grid[i][j] ?? 0) > 0 && energy == 2 || energy == 3;
        double value = alive ? 1 : 0; //grid[i][j] + 0.5 : grid[i][j] - 0.5;

        row.add(clamp(value, 0, maxHeight));
      }
      newGrid.add(row);
    }
    return newGrid;
  }

  double getNeighboursCount(List<List<double>> grid, int x, int y) {
    double count = 0;
    for (int i = 0; i < 8; i++) {
      count += getNeighbour(grid, x, y, i) > 0 ? 1 : 0;
    }
    return count;
  }

  double getNeighbour(List<List<double>> grid, int x, int y, int index) {
    int nx = x;
    int ny = y;
    if (index < 3) {
      ny = y - 1;
      nx = x + index - 1;
    } else if (index < 5) {
      ny = y;
      nx = index == 3 ? x - 1 : x + 1;
    } else {
      ny = y + 1;
      nx = x + (index - 5) - 1;
    }
    return grid[nx % size][ny % size];
  }

  List<List<double>> lerpGrid(double value, List<List<double>> previousGrid, List<List<double>> grid) {
    List<List<double>> newGrid = [];
    for (int i = 0; i < grid.length; i++) {
      List<double> row = [];
      for (int j = 0; j < grid[i].length; j++) {
        row.add(lerpDouble(previousGrid[i][j], grid[i][j], value));
      }
      newGrid.add(row);
    }
    return newGrid;
  }

  double clamp(double value, double minValue, double maxValue) {
    return min(maxValue, max(minValue, value));
  }
}
