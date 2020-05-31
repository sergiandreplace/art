import 'dart:math';

import 'package:flutter/material.dart';

import '../isometric.dart';

class IsometricWave extends StatefulWidget {
  @override
  _IsometricWaveState createState() => _IsometricWaveState();
}

class _IsometricWaveState extends State<IsometricWave> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  List<List<double>> grid = [];
  final double maxHeight = 6;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    animationController.duration = Duration(seconds: 5);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) animationController.forward(from: 0);
    });
    animationController.forward(from: 0);
    animationController.addListener(() => setState(() {
          double time = animationController.value;
          grid = [];
          int size = 20;
          for (double i = 0; i < size; i++) {
            List<double> row = [];
            for (double j = 0; j < size; j++) {
              var id = pi * 2 * time + pi * i / size;
              var ij = pi * 2 * time + pi * j / size;
              if ((i + j) % 3 == 0) {
                row.add(maxHeight / 2 + sin(id) * cos(ij) * maxHeight / 2);
              } else {
                row.add(0);
              }
            }
            grid.add(row);
          }
          time = animationController.value;
          // animationController.stop();
        }));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Isometric(
      grid,
      maxHeight: maxHeight,
    );
  }
}
