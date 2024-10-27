import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'enemy.dart';
import 'player.dart';

class Orc extends Enemy {
  Orc(double speed, int tileSize, List<List<int>> dungeon, Player player) : super(speed, tileSize, dungeon, player);

  @override
  Future<SpriteSheet> loadSpriteSheet() async {
    return SpriteSheet(
      image: await gameRef.images.load('orc.png'),
      srcSize: Vector2(100.0, 100.0),
    );
  }

  @override
  void move(Vector2 delta) {
    position.add(delta);
  }
}