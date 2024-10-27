import 'enemy.dart';
import 'movement_strategy.dart';
import 'player.dart';
import 'orc.dart';

class EnemyPool {
  final List<Enemy> _available = [];
  final List<Enemy> _inUse = [];

  Enemy getEnemy(MovementStrategy strategy, double speed, int tileSize, List<List<int>> dungeon, Player player) {
    if (_available.isEmpty) {
      final enemy = Orc(strategy, speed, tileSize, dungeon, player); 
      _inUse.add(enemy);
      return enemy;
    } else {
      final enemy = _available.removeLast();
      enemy.movementStrategy = strategy; // Update the strategy for the reused enemy
      _inUse.add(enemy);
      return enemy;
    }
  }

  void releaseEnemy(Enemy enemy) {
    _inUse.remove(enemy);
    _available.add(enemy);
  }
}