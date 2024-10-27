import 'package:flutter/material.dart';
import 'dart:html' as html;

class WinScreen extends StatelessWidget {
  final VoidCallback onReplay;

  const WinScreen({required this.onReplay, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You Win!',
            style: TextStyle(
              fontSize: 48,
              color: Colors.green, // Changed color to green for better visibility
              fontFamily: 'PublicPixel', // Use the custom font
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              html.window.location.reload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Button background color
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