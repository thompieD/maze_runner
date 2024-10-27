import 'player.dart';

abstract class PlayerState {
  void enter(Player player);
  void update(Player player, double dt);
  void exit(Player player);
}

class IdleState implements PlayerState {
  @override
  void enter(Player player) {
    player.animation = player.idleAnimation;
  }

  @override
  void update(Player player, double dt) {
    if (player.direction.length > 0) {
      player.setState(RunningState());
    }
  }

  @override
  void exit(Player player) {}
}

class RunningState implements PlayerState {
  @override
  void enter(Player player) {
    player.animation = player.runAnimation;
  }

  @override
  void update(Player player, double dt) {
    if (player.direction.length == 0) {
      player.setState(IdleState());
    }
  }

  @override
  void exit(Player player) {}
}

class DamagedState implements PlayerState {
  @override
  void enter(Player player) {
    player.animation = player.damageAnimation;
    player.invincible = true;
    Future.delayed(Duration(seconds: 5), () {
      player.invincible = false;
      player.setState(IdleState());
    });
  }

  @override
  void update(Player player, double dt) {}

  @override
  void exit(Player player) {}
}

class AttackingState implements PlayerState {
  @override
  void enter(Player player) {
    player.animation = player.attackAnimation;
    Future.delayed(Duration(seconds: 1), () {
      player.setState(IdleState());
    });
  }

  @override
  void update(Player player, double dt) {}

  @override
  void exit(Player player) {}
}