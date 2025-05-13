import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pet_care_shop/screens/login_screen.dart';
import 'package:pet_care_shop/screens/signup_screen.dart';
import 'package:pet_care_shop/screens/home_screen.dart';
import 'package:pet_care_shop/screens/shop_screen.dart';
import 'package:pet_care_shop/screens/vet_screen.dart';
import 'package:pet_care_shop/screens/profile_screen.dart';
import 'package:pet_care_shop/screens/cart_screen.dart';
import 'package:pet_care_shop/screens/checkout_screen.dart';
import 'package:pet_care_shop/screens/success_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pet_care_shop/providers/cart_provider.dart';
import 'package:pet_care_shop/utils/stripe_config.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/shop': (context) => ShopScreen(category: 'All'),
        '/vet': (context) => VetScreen(),
        '/profile': (context) => ProfileScreen(),
        '/cart': (context) => CartScreen(),
        '/success': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return SuccessScreen(itemCount: args['itemCount']);
        },
      },
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/checkout') {
      //     final args = settings.arguments as Map<String, dynamic>;
      //     return MaterialPageRoute(
      //       builder: (context) => CheckoutScreen(
      //         itemCount: args['itemCount'],
      //         purchaseIds: args['purchaseIds'],
      //         totalAmount: args['totalAmount'],
      //       ),
      //     );
      //   }
      //   return null;
      // },
    );
  }
}
