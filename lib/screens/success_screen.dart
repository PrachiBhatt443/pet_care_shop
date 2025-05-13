import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  final int itemCount;

  const SuccessScreen({Key? key, required this.itemCount}) : super(key: key);

  // Theme colors
  static const orangeTheme = Color(0xFFFFA726);
  static const creamTheme = Color(0xFFFFF8E1);
  static const textBrown = Color(0xFF8D6E63);
  static const buttonOrange = Color(0xFFE67E22);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamTheme,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textBrown,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your order of $itemCount ${itemCount == 1 ? 'item' : 'items'} has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textBrown.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your purchase!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: textBrown.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to order history or tracking screen
                    Navigator.of(context).pushNamed('/orders');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View My Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate back to home
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      color: orangeTheme,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}