import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
Future createPaymentIntent({
  required String name,
  required String pin,
  required String city,
  required String state,
  required String country,
  required String currency,
   required String amount
}) async{
  final url = Uri.parse("https://api.stripe.com/v1/payment_intents");
  final secretKey = dotenv.env['STRIPE_SECRET_KEY'];
  final body = {
    'amount': amount,
    'currency': currency,
    'automatic_payment_methods[enabled]': 'true',
    'description': 'Payment for Pet Shop',
    'shipping[name]': name,
    'shipping[address][line1]': '123 Main St',
    'shipping[address][postal_code]': pin,
    'shipping[address][city]': city,
    'shipping[address][state]': state,
    'shipping[address][country]': country,
  };
  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $secretKey",
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body,
  );
  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    print('Payment Intent Created: ${responseBody['id']}');
    return responseBody;
  } else {
    print('Failed to create payment intent: ${response.body}');
  }

}