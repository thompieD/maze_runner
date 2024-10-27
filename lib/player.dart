import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:maze_runner/enemy.dart';
import 'package:maze_runner/game.dart';

const int PATH_TILE = 0;
const int WALL_TILE = 1;

enum PlayerState { idle, running, damaged, attacking }

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

  PlayerState _state = PlayerState.idle;
  bool _isDamageAnimationPlaying = false;

  Player(this.dungeon, this.tileSize) : super(size: Vector2(tileSize.toDouble(), tileSize.toDouble()), priority: 0);

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('soldier.png'),
      srcSize: Vector2(100.0, 100.0),
    );

    // Create idle animation from the sprite sheet at coordinates (0, 0)
    idleAnimation = createCustomAnimation(spriteSheet, row: 0, stepTime: 0.1, from: 0, to: 5);

    // Create run animation from the sprite sheet at coordinates (1, 0)
    runAnimation = createCustomAnimation(spriteSheet, row: 1, stepTime: 0.1, from: 0, to: 5);

    // Create damage animation from the sprite sheet at coordinates (5, 0)
    damageAnimation = createCustomAnimation(spriteSheet, row: 5, stepTime: 0.1, from: 0, to: 4);

    // Create attack animation from the sprite sheet at coordinates (6, 0)
    attackAnimation = createCustomAnimation(spriteSheet, row: 2, stepTime: 0.1, from: 0, to: 5);

    // Set the initial animation to idle
    animation = idleAnimation;

    // Set the initial position to a path tile
    position = findPathTile();

    // Add a hitbox for collision detection
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
        // Check for path tile
        if (dungeon[y][x] == PATH_TILE) {
          return Vector2(x.toDouble() * tileSize, y.toDouble() * tileSize);
        }
      }
    }
    // Default position if no suitable path tile is found
    return Vector2(0, 0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    handleInput(dt);

    // Update animation based on state
    if (_isDamageAnimationPlaying) {
      // Do not update animation if damage animation is playing
      return;
    }

    switch (_state) {
      case PlayerState.idle:
        if (animation != idleAnimation) {
          animation = idleAnimation;
        }
        break;
      case PlayerState.running:
        if (animation != runAnimation) {
          animation = runAnimation;
        }
        break;
      case PlayerState.damaged:
        if (animation != damageAnimation) {
          animation = damageAnimation;
          _isDamageAnimationPlaying = true;
          Future.delayed(Duration(seconds: 1), () {
            _isDamageAnimationPlaying = false;
            _state = PlayerState.idle; // Reset state to idle after damage animation
          });
        }
        break;
      case PlayerState.attacking:
        if (animation != attackAnimation) {
          animation = attackAnimation;
          Future.delayed(Duration(seconds: 1), () {
            _state = PlayerState.idle; // Reset state to idle after attack animation
          });
        }
        break;
    }

  }

  void handleInput(double dt) {
    if (_state != PlayerState.damaged && _state != PlayerState.attacking) {
      if (direction.length > 0) {
        direction = direction.normalized();
        _state = PlayerState.running; // Switch to running state
      } else {
        _state = PlayerState.idle; // Switch to idle state
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
  void attack() {
    if (_state != PlayerState.attacking) {
      _state = PlayerState.attacking;
      animation = attackAnimation;

      // Check for nearby enemies and remove them
      final attackRange = tileSize.toDouble();
      gameRef.children.whereType<Enemy>().forEach((enemy) {
        if (position.distanceTo(enemy.position) <= attackRange) {
          // Make the enemy do a dead animation and remove it from the game
          enemy.animation = enemy.deadAnimation;
          Future.delayed(Duration(milliseconds: 500), () {
            // Check if the enemy is still part of the game
            if (enemy.parent != null) {
              // Remove the enemy from the orc list
              (gameRef as MazeRunnerGame).orcs.remove(enemy);
              enemy.removeFromParent();
            }
          });
        }
      });

      // Reset state to idle after attack animation
      Future.delayed(Duration(seconds: 1), () {
        _state = PlayerState.idle;
      });
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
      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        attack();
      }
      return true;
    }

  // Getter for state
  PlayerState get playerState => _state;

  // Setter for state
  set playerState(PlayerState newState) {
    _state = newState;
  }
}