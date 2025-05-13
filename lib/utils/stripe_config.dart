import 'package:flutter_stripe/flutter_stripe.dart';

class StripeConfig {
  // This is your test publishable key - replace with your actual key for production
  static const String publishableKey = 'pk_test_51QQrbQHfC1xxeiXgcgkgMFCQRWWqtwgvpaFiOaUYm0Dj65ueGIRNYI1ow0QCfR4XqyIlUwKejXJzqfqD6XLpX928001fxckZoD';

  static Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
}