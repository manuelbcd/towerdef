import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const TowerDefApp());
}

class TowerDefApp extends StatelessWidget {
  const TowerDefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}
