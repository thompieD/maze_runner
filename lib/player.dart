import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';

const int PATH_TILE = 0;
const int WALL_TILE = 1;

class Player extends SpriteAnimationComponent with HasGameRef<FlameGame>, KeyboardHandler, CollisionCallbacks {
  final double speed = 100.0; 
  final int tileSize;
  late List<List<int>> dungeon; 

  Vector2 direction = Vector2.zero();
  late RectangleHitbox hitbox;

  late SpriteAnimation idleAnimation;
  late SpriteAnimation runAnimation;

  Player(this.dungeon, this.tileSize) : super(size: Vector2(tileSize.toDouble() * 5, tileSize.toDouble() * 5), priority: 0); // Set lower priority

  @override
  Future<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('soldier.png'),
      srcSize: Vector2(100.0, 100.0),
    );

    // Create idle animation from the sprite sheet at coordinates (0, 0)
    idleAnimation = spriteSheet.createAnimation(row: 0, stepTime: 0.1, from: 0, to: 5);

    // Create run animation from the sprite sheet at coordinates (1, 0)
    runAnimation = spriteSheet.createAnimation(row: 1, stepTime: 0.1, from: 0, to: 5);

    // Set the initial animation to idle
    animation = idleAnimation;

    // Set the initial position to a path tile
    position = findPathTile();

    // Add a hitbox for collision detection
    hitbox = RectangleHitbox.relative(Vector2(1, 1), parentSize: size); // Slightly larger hitbox
    add(hitbox);

    print('Player initial position: $position');
  }

  Vector2 findPathTile() {
    for (int y = 0; y < dungeon.length; y++) {
      for (int x = 0; x < dungeon[y].length; x++) {
        // Check for path tile
        if (dungeon[y][x] == PATH_TILE) {
          print('Found path tile at: ($x, $y)');
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
  }

  void handleInput(double dt) {
    if (direction.length > 0) {
      direction = direction.normalized();
      animation = runAnimation; // Switch to run animation
    } else {
      animation = idleAnimation; // Switch to idle animation
    }
    final delta = direction * speed * dt;
    move(delta);
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
    print('Key event: $event');

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

    print('Direction: $direction');

    return true;
  }
}