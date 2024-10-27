import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'maze.dart';
import 'player.dart';
import 'orc.dart';
import 'dart:math';

class MazeRunnerGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Maze maze;
  late Player player;
  late List<Orc> orcs;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = false;

    // Add maze
    maze = Maze(32, 50, 27, this);
    await add(maze);

    // Ensure the maze is fully loaded before adding the player
    await Future.delayed(Duration(milliseconds: 100));

    // Add player
    player = Player(maze.dungeon, maze.tileSize);
    await add(player);

    // Get a random number between 3 and 6 and spawn orcs
    final random = Random();
    int numOrcs = 3 + random.nextInt(4); // random.nextInt(4) generates a number between 0 and 3, so 3 + 0 to 3 + 3 gives 3 to 6
    orcs = List.generate(numOrcs, (index) => Orc(50.0, maze.tileSize, maze.dungeon, player));
    for (Orc orc in orcs) {
      await add(orc);
    }

    print('Player and orcs added to the game');
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