// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:pet_care_shop/services/auth_service.dart';
//
// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }
//
// class _SignupScreenState extends State<SignupScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _authService = AuthService();
//
//   Future<void> _signUp() async {
//     final email = _emailController.text;
//     final password = _passwordController.text;
//
//     try {
//       await _authService.signUpWithEmailPassword(email, password);
//       Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sign Up Failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFFFF8E1), // Bright cream
//       body: Center(
//         child: SingleChildScrollView(
//           child: Card(
//             margin: EdgeInsets.symmetric(horizontal: 24),
//             elevation: 10,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//             color: Color(0xFFFFCC80), // Vibrant orange
//             child: Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Create Your Account',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF4E342E), // Deep brown
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     'Join our community',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFFE64A19), // Burnt orange
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email, color: Color(0xFF4E342E)),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   TextField(
//                     controller: _passwordController,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: Icon(Icons.lock, color: Color(0xFF4E342E)),
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
//                     ),
//                     obscureText: true,
//                   ),
//                   SizedBox(height: 24),
//                   ElevatedButton(
//                     onPressed: _signUp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFD84315), // Vibrant brown
//                       padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
//                   ),
//                   SizedBox(height: 12),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       'Already have an account? Log In',
//                       style: TextStyle(color: Color(0xFF4E342E)),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:pet_care_shop/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await _authService.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Color(0xFFFFCC80),
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Create Your Account',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4E342E))),
                  SizedBox(height: 10),
                  Text('Join our community',
                      style: TextStyle(fontSize: 16, color: Color(0xFFE64A19))),
                  SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF4E342E)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF4E342E)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF4E342E)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD84315),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Sign Up', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Already have an account? Log In', style: TextStyle(color: Color(0xFF4E342E))),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

