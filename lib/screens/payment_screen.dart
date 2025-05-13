import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<void> _makePayment() async {
    try {
      // Step 1: Request Payment Intent from Backend
      String? clientSecret = await PaymentService.createPaymentIntent(1000); // Amount in cents

      if (clientSecret == null) {
        print("Failed to get clientSecret");
        return;
      }

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "My Store",
        ),
      );

      // Step 3: Show Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      print("Payment Successful!");
    } catch (e) {
      print("Payment Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stripe Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: _makePayment,
          child: Text("Pay \$10"),
        ),
      ),
    );
  }
}