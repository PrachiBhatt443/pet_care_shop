import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final String username;
  const WelcomeHeader({required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hi $username!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Welcome to Pet Care Shop 🐾', style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}
