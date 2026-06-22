import 'package:flutter/material.dart';

class BlastEffect {
  final Offset position;
  final double radius;
  final double duration;

  double elapsed = 0;

  BlastEffect({
    required this.position,
    required this.radius,
    this.duration = 0.55,
  });

  double get progress => (elapsed / duration).clamp(0.0, 1.0);

  bool get isFinished => elapsed >= duration;

  void update(double deltaTime) {
    elapsed += deltaTime;
  }
}
