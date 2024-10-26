import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class TestEnclosure extends Component {
  final int tileSize;
  final FlameGame gameRef;
  late SpriteSheet spriteSheet;

  TestEnclosure(this.tileSize, this.gameRef);

  @override
  Future<void> onLoad() async {
    spriteSheet = SpriteSheet(
      image: await gameRef.images.load('dungeon_tileset.png'),
      srcSize: Vector2(16.0, 16.0), // Each sprite is 16x16 pixels
    );

    // Create a 2x2 grid to test the 4 corner wall sprites
    addTile(0, 0, 1, 0); // Top-left corner
    addTile(1, 0, 3, 1); // Top-right corner
    addTile(0, 1, 4, 0); // Bottom-left corner
    addTile(1, 1, 4, 1); // Bottom-right corner
  }

  void addTile(int x, int y, int spriteX, int spriteY) {
    final tile = SpriteComponent()
      ..sprite = spriteSheet.getSprite(spriteX, spriteY)
      ..size = Vector2(tileSize.toDouble(), tileSize.toDouble())
      ..position = Vector2(x * tileSize.toDouble(), y * tileSize.toDouble());
    add(tile);
  }
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final testEnclosure = TestEnclosure(32, this); // Assuming tileSize is 32
    await add(testEnclosure);
  }
}

void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}