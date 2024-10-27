import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart' as audio;  
import 'package:flutter/services.dart';
import 'player_state.dart';
import 'enemy.dart';
import 'game.dart';
import 'maze.dart';

class Player extends SpriteAnimationComponent with HasGameRef<FlameGame>, KeyboardHandler, CollisionCallbacks {
  final double speed = 100.0; 
  int lives = 3;
  bool invincible = false;
  final int tileSize;
  late List<List<int>> dungeon; 

  Vector2 direction = Vector2.zero();
  late RectangleHitbox hitbox;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;
  late SpriteAnimation damageAnimation;
  late SpriteAnimation attackAnimation;

  PlayerState _state = IdleState();

  Player(this.dungeon, this.tileSize) : super(size: Vector2(tileSize.toDouble(), tileSize.toDouble()), priority: 0);

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('soldier.png'),
      srcSize: Vector2(100.0, 100.0),
    );

    idleAnimation = createCustomAnimation(spriteSheet, row: 0, stepTime: 0.1, from: 0, to: 5);
    runAnimation = createCustomAnimation(spriteSheet, row: 1, stepTime: 0.1, from: 0, to: 5);
    damageAnimation = createCustomAnimation(spriteSheet, row: 5, stepTime: 0.1, from: 0, to: 4);
    attackAnimation = createCustomAnimation(spriteSheet, row: 2, stepTime: 0.1, from: 0, to: 5);

    animation = idleAnimation;
    position = findPathTile();
    hitbox = RectangleHitbox.relative(Vector2(1, 1), parentSize: size); 
    add(hitbox);
  }

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
    for (int y = 0; y < dungeon.length; y++) {
      for (int x = 0; x < dungeon[y].length; x++) {
        if (dungeon[y][x] == PATH_TILE) {
          return Vector2(x.toDouble() * tileSize, y.toDouble() * tileSize);
        }
      }
    }
    return Vector2(0, 0);
  }

  void setState(PlayerState newState) {
    _state.exit(this);
    _state = newState;
    _state.enter(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    handleInput(dt);
    _state.update(this, dt);
  }

  void handleInput(double dt) {
    if (_state is! AttackingState) {
      if (direction.length > 0) {
        direction = direction.normalized();
        if (_state is! DamagedState) {
          setState(RunningState());
        }
      } else {
        setState(IdleState());
      }
      final delta = direction * speed * dt;
      move(delta);
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

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    direction = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space) && _state is! DamagedState) {
      attack();
    }
    return true;
  }

  void attack() {
    if (_state is! AttackingState) {
      setState(AttackingState());

      // Play sword swing sound effect
      audio.FlameAudio.play('swing.wav');

      final attackRange = tileSize.toDouble();
      gameRef.children.whereType<Enemy>().forEach((enemy) {
        if (position.distanceTo(enemy.position) <= attackRange) {
          enemy.animation = enemy.deadAnimation;
          Future.delayed(Duration(milliseconds: 500), () {
            if (enemy.parent != null) {
              (gameRef as MazeRunnerGame).orcs.remove(enemy);
              (gameRef as MazeRunnerGame).releaseEnemy(enemy);
              enemy.removeFromParent();
            }
          });
        }
      });

      Future.delayed(Duration(milliseconds: 600), () {
        setState(IdleState());
      });
    }
  }
}