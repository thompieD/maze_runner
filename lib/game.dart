import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'maze.dart';

class MazeRunnerGame extends FlameGame {
  late Maze maze;

  @override
  Future<void> onLoad() async {
    await super.onLoad();




    // Add maze
    maze = Maze(32, 20, 15, this);
    add(maze);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update game logic here
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render game elements here
  }
}