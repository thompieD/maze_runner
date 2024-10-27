import 'package:flame/events.dart';
import 'dart:html' as html;
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'livesdisplay.dart';
import 'winscreen.dart';
import 'losescreen.dart';
import 'maze.dart';
import 'player.dart';
import 'orc.dart';
import 'dart:math';
import 'enemy_pool.dart';
import 'movement_strategy.dart';
import 'enemy.dart';

class MazeRunnerGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  final BuildContext context;
  late Maze maze;
  late Player player;
  late List<Orc> orcs;
  late LivesDisplay livesDisplay;
  OverlayEntry? winOverlay;
  OverlayEntry? loseOverlay;

  final EnemyPool enemyPool = EnemyPool();

  MazeRunnerGame(this.context);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    debugMode = false;

    // Load and play background music
    FlameAudio.bgm.initialize();
    FlameAudio.loop('background_music.mp3', volume: 0.4);

    // Add maze
    maze = Maze(32, 50, 27, this);
    await add(maze);

    // Ensure the maze is fully loaded before adding the player
    await Future.delayed(Duration(milliseconds: 100));

    // Add player
    player = Player(maze.dungeon, maze.tileSize);
    await add(player);

    // Add lives display
    livesDisplay = LivesDisplay(player);
    await add(livesDisplay);

    // Get a random number between 3 and 6 and spawn orcs
    final random = Random();
    int numOrcs = 3 + random.nextInt(4);
    orcs = List.generate(numOrcs, (index) {
      final enemy = enemyPool.getEnemy(FollowPlayerMovementStrategy(), 20.0, maze.tileSize, maze.dungeon, player); // Adjusted speed to 20.0
      add(enemy);
      return enemy as Orc;
    });
  }

  void releaseEnemy(Enemy enemy) {
    enemyPool.releaseEnemy(enemy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player.lives <= 0) {
      showLoseScreen();
    }

    if (orcs.isEmpty) {
      print('You win');
      showWinScreen();
    }
  }

  void showWinScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      winOverlay = OverlayEntry(
        builder: (context) => WinScreen(
          onReplay: () {
            html.window.location.reload();
          },
        ),
      );
      Overlay.of(context).insert(winOverlay!);
    });
  }

  void showLoseScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loseOverlay = OverlayEntry(
        builder: (context) => LoseScreen(
          onReplay: () {
            html.window.location.reload();
          },
        ),
      );
      Overlay.of(context).insert(loseOverlay!);
    });
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final result = super.onKeyEvent(event, keysPressed);
    if (result == KeyEventResult.handled) {
      return result;
    }

    return KeyEventResult.handled;
  }
}