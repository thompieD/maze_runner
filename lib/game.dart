import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'maze.dart';
import 'player.dart';

class MazeRunnerGame extends FlameGame with HasKeyboardHandlerComponents {
  late Maze maze;
  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add maze
    maze = Maze(32, 30, 30, this);
    await add(maze);

    // Ensure the maze is fully loaded before adding the player
    await Future.delayed(Duration(milliseconds: 100));

    // Add player
    player = Player(maze.dungeon, maze.tileSize);
    await add(player);

    print('Player added to the game');
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

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Call the superclass's onKeyEvent method
    final result = super.onKeyEvent(event, keysPressed);
    if (result == KeyEventResult.handled) {
      return result;
    }

    // Handle keyboard events here
    return KeyEventResult.handled;
  }
}