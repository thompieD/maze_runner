import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'player.dart';

class LivesDisplay extends Component with HasGameRef<FlameGame> {
  final Player player;
  late Sprite heartSprite;
  final double heartSize = 24.0;
  final double spacing = 5.0;

  LivesDisplay(this.player) : super(priority: 1);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final spriteSheet = await gameRef.images.load('hearts.png');
    heartSprite = Sprite(
      spriteSheet,
      srcPosition: Vector2(0, 0),
      srcSize: Vector2(16, 16),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    for (int i = 0; i < player.lives; i++) {
      heartSprite.render(
        canvas,
        position: Vector2(10 + i * (heartSize + spacing), 10),
        size: Vector2(heartSize, heartSize),
      );
    }
  }
}