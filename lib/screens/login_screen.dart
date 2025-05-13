import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_care_shop/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {

      final userCredential = await _authService.signInWithEmailPassword(email, password);
      // final user = FirebaseAuth.instance.currentUser;
      // final user = userCredential.user;
      print("usercredentials");
      print(userCredential);
      final user = userCredential?.uid;
      if (user == null) {
        throw Exception("User is null after sign-in");
      }
      print("id");
      print(user);
      final snapshot = await FirebaseFirestore.instance
        .collection('purchases')
        .where('userId', isEqualTo: user)
        .where('status', isEqualTo: 'Pending')
        .get();

      print("snapshot");
      print(snapshot);

      final purchaseData = snapshot.docs.map((doc) => doc.data()).toList();
      print(":");
      print(purchaseData);
      Provider.of<CartProvider>(context, listen: false)
          .initializeCartFromPurchases(purchaseData);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFFFF8F0), // Soft peachy background
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.06),

            // Image with padding and centered
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/dog_cat.png',
                  height: screenHeight * 0.28,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 20),

            // Login Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Color(0xFFFFCC80), // Rich orange shade
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E342E), // Deep brown
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Login to your Pet Care account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: Colors.deepOrange),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD84315), // Deep orange

                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Login', style: TextStyle(fontSize: 18,color: Colors.white)),
                      ),
                      SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(color: Color(0xFF4E342E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
