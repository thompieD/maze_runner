import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'movement_strategy.dart';
import 'enemy.dart';
import 'player.dart';
import 'maze.dart';

class Orc extends Enemy {
  Orc(MovementStrategy strategy, double speed, int tileSize, List<List<int>> dungeon, Player player)
      : super(strategy, speed, tileSize, dungeon, player);

  @override
  Future<SpriteSheet> loadSpriteSheet() async {
    return SpriteSheet(
      image: await gameRef.images.load('orc.png'),
      srcSize: Vector2(100.0, 100.0),
    );
  }

  @override
  void move(Vector2 delta) {
    final newPosition = position + delta;
    final tileX = ((newPosition.x + size.x / 2) / tileSize).floor();
    final tileY = ((newPosition.y + size.y / 2) / tileSize).floor();

    if (tileX >= 0 && tileX < dungeon[0].length && tileY >= 0 && tileY < dungeon.length && dungeon[tileY][tileX] == PATH_TILE) {
      position.add(delta);
    }
  }
}