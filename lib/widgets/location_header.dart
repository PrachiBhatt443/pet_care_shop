import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String location;

  const LocationHeader({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              const Text(
                'Your Current Spot',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                location,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.orange[800]),
        ],
      ),
    );
  }
}