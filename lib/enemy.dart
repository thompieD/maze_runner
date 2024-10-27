import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'player.dart';

abstract class Enemy extends SpriteAnimationComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  final double speed;
  final int tileSize;
  late List<List<int>> dungeon;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;
  late SpriteAnimation attackAnimation; 
  late Player player; 

  Enemy(this.speed, this.tileSize, this.dungeon, this.player) : super(size: Vector2(tileSize.toDouble(), tileSize.toDouble()), priority: 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());

    final spriteSheet = await loadSpriteSheet();
    idleAnimation = createCustomAnimation(spriteSheet, row: 0, stepTime: 0.1, from: 0, to: 5);
    walkAnimation = createCustomAnimation(spriteSheet, row: 1, stepTime: 0.1, from: 0, to: 5);
    attackAnimation = createCustomAnimation(spriteSheet, row: 2, stepTime: 0.1, from: 0, to: 5); // Load attack animation

    // Set the initial animation to idle
    animation = idleAnimation;

    // Set the initial position to a path tile
    position = findPathTile();

    print('Enemy initial position: $position');
  }

  Future<SpriteSheet> loadSpriteSheet();

  SpriteAnimation createCustomAnimation(SpriteSheet spriteSheet, {required int row, required double stepTime, required int from, required int to}) {
    final frames = <SpriteAnimationFrame>[];
    for (int i = from; i <= to; i++) {
      final sprite = spriteSheet.getSprite(row, i);
      final customSprite = Sprite(
        sprite.image,
        srcPosition: sprite.srcPosition + Vector2(34, 34), 
        srcSize: Vector2(32, 32),
      );
      frames.add(SpriteAnimationFrame(customSprite, stepTime));
    }
    return SpriteAnimation(frames);
  }

  Vector2 findPathTile() {
    final random = Random();
    while (true) {
      int x = random.nextInt(dungeon[0].length);
      int y = random.nextInt(dungeon.length);
      if (dungeon[y][x] == PATH_TILE) {
        return Vector2(x.toDouble() * tileSize, y.toDouble() * tileSize);
      }
    }
  }

  void move(Vector2 delta) {
    final newPosition = position + delta;
    final tileX = ((newPosition.x + size.x / 2) / tileSize).floor();
    final tileY = ((newPosition.y + size.y / 2) / tileSize).floor();
  
    print('Attempting to move to: $newPosition, tile: ($tileX, $tileY)');
  
    if (tileX >= 0 && tileX < dungeon[0].length && tileY >= 0 && tileY < dungeon.length && dungeon[tileY][tileX] == PATH_TILE) {
      position.add(delta);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
  
    final distanceToPlayer = position.distanceTo(player.position);
  
    if (distanceToPlayer <= tileSize - 16) {
      animation = attackAnimation;
      if (!player.invincible) {
        player.lives -= 1;
        player.invincible = true;
        player.playerState = PlayerState.damaged;
        Future.delayed(Duration(seconds: 1), () {
          player.invincible = false;
        // Set player state to damaged
          player.playerState = PlayerState.idle;
          
        });
      }
    } else if (distanceToPlayer <= 4 * tileSize) {
      // Enemy is close enough to move towards the player
      final delta = (player.position - position).normalized() * speed * dt;
      print('Moving enemy. Current position: $position, Player position: ${player.position}, Delta: $delta');
      move(delta);
      animation = walkAnimation;
    } else {
      // Enemy is idle
      animation = idleAnimation;
    }
  }
}