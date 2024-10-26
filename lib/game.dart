import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class MazeRunnerGame extends FlameGame {
  late SpriteComponent player;
  late TextComponent textComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add text component
    textComponent = TextComponent(
      text: 'Maze Runner Game',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      position: Vector2(10, 10),
    );
    add(textComponent);
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