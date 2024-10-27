import 'enemy.dart';
import 'dart:math';
import 'package:flame/components.dart';

abstract class MovementStrategy {
  void move(Enemy enemy, double dt);
}

class RandomMovementStrategy implements MovementStrategy {
  @override
  void move(Enemy enemy, double dt) {
    // Implement random movement logic
    // Example: Move the enemy randomly within the dungeon
    final random = Random();
    final direction = Vector2(random.nextDouble() - 0.5, random.nextDouble() - 0.5).normalized();
    final delta = direction * enemy.speed * dt;
    enemy.move(delta);
  }
}

class FollowPlayerMovementStrategy implements MovementStrategy {
  @override
  void move(Enemy enemy, double dt) {
    final distanceToPlayer = enemy.position.distanceTo(enemy.player.position);
    if (distanceToPlayer <= 4 * enemy.tileSize) {
      final delta = (enemy.player.position - enemy.position).normalized() * enemy.speed * dt;
      enemy.move(delta);
    }
  }
}