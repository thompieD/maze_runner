import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart'; // Import the game.dart file

void main() {
  runApp(GameWidget(game: MazeRunnerGame()));
}