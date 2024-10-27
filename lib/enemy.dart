import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'maze.dart';
import 'player.dart';
import 'movement_strategy.dart';
import 'player_state.dart'; 

enum EnemyState { idle, walking, attacking, dead }

abstract class Enemy extends SpriteAnimationComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  final double speed;
  final int tileSize;
  late List<List<int>> dungeon;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation walkAnimation;
  late SpriteAnimation attackAnimation; 
  late SpriteAnimation deadAnimation;
  late Player player; 

  EnemyState _state = EnemyState.idle;
  final bool _isAttackAnimationPlaying = false;
  bool _isDeadAnimationPlaying = false;

  MovementStrategy movementStrategy;

  Enemy(this.movementStrategy, this.speed, this.tileSize, this.dungeon, this.player) : super(size: Vector2(tileSize.toDouble(), tileSize.toDouble()), priority: 0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());

    final spriteSheet = await loadSpriteSheet();
    idleAnimation = createCustomAnimation(spriteSheet, row: 0, stepTime: 0.1, from: 0, to: 5);
    walkAnimation = createCustomAnimation(spriteSheet, row: 1, stepTime: 0.1, from: 0, to: 5);
    attackAnimation = createCustomAnimation(spriteSheet, row: 2, stepTime: 0.1, from: 0, to: 5); 
    deadAnimation = createCustomAnimation(spriteSheet, row: 5, stepTime: 0.1, from: 0, to: 3);

    // Set the initial animation to idle
    animation = idleAnimation;

    // Set the initial position to a path tile
    position = findPathTile();
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

  @override
  void update(double dt) {
    super.update(dt);
    movementStrategy.move(this, dt);
  
    final distanceToPlayer = position.distanceTo(player.position);
  
    if (distanceToPlayer <= tileSize - 16) {
      _state = EnemyState.attacking;
      if (!player.invincible) {
        player.lives -= 1;
        player.setState(DamagedState());
      }
    } else if (distanceToPlayer <= 4 * tileSize) {
      // Enemy is close enough to move towards the player
      _state = EnemyState.walking;
      final delta = (player.position - position).normalized() * speed * dt;
      move(delta);
    } else {
      _state = EnemyState.idle;
    }

    // Update animation based on state
    if (_isAttackAnimationPlaying || _isDeadAnimationPlaying) {
      // Do not update animation if attack or dead animation is playing
      return;
    }

    switch (_state) {
      case EnemyState.idle:
        if (animation != idleAnimation) {
          animation = idleAnimation;
        }
        break;
      case EnemyState.walking:
        if (animation != walkAnimation) {
          animation = walkAnimation;
        }
        break;
      case EnemyState.attacking:
        if (animation != attackAnimation) {
          animation = attackAnimation;
        }
        break;
      case EnemyState.dead:
        if (animation != deadAnimation) {
          animation = deadAnimation;
          _isDeadAnimationPlaying = true;
          Future.delayed(Duration(milliseconds: 500), () {
            _isDeadAnimationPlaying = false;
            removeFromParent(); // Remove enemy after dead animation
          });
        }
        break;
    }
  }

  void move(Vector2 delta) {
    final newPosition = position + delta;
    final tileX = ((newPosition.x + size.x / 2) / tileSize).floor();
    final tileY = ((newPosition.y + size.y / 2) / tileSize).floor();

    if (tileX >= 0 && tileX < dungeon[0].length && tileY >= 0 && tileY < dungeon.length && dungeon[tileY][tileX] == PATH_TILE) {
      position.add(delta);
    }
  }
}