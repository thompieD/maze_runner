import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart'; // Import your game file

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Stack(
              children: [
                GameWidget(
                  game: MazeRunnerGame(context),
                ),
                Overlay(
                  initialEntries: [],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}