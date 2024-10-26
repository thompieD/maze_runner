import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  runApp(GameWidget(game: MazeGame()));
}

class MazeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Placeholder for loading assets or game components
  }
}
