// import 'package:flutter/material.dart';
//
// void main() {
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//

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
