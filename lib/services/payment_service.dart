import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static Future<String?> createPaymentIntent(int amount) async {
    try {
      var response = await http.post(
        Uri.parse("https://your-backend-url.com/create-payment-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount, "currency": "usd"}),
      );

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse["clientSecret"];
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}