import 'package:flutter/material.dart';
import 'dart:html' as html;

class LoseScreen extends StatelessWidget {
  final VoidCallback onReplay;

  const LoseScreen({required this.onReplay, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You Lose!',
            style: TextStyle(
              fontSize: 48,
              color: Colors.red,
              fontFamily: 'PublicPixel', // Use the correct font family name
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              html.window.location.reload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: TextStyle(fontSize: 20, color: Colors.white),
            ),
            child: Text('Replay'),
          ),
        ],
      ),
    );
  }
}