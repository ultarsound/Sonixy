import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobService {
  static const String _apiKey = "";
  static const int _integrationId = 123456;
  static const String _authUrl = "https://accept.paymob.com/api/auth/tokens";

  static const String _orderUrl =
      "https://accept.paymob.com/api/ecommerce/orders";

  static const String _paymentKeyUrl =
      "https://accept.paymob.com/api/acceptance/payment_keys";

  // 1️⃣ Auth Token
  static Future<String> getAuthToken() async {
    final response = await http.post(
      Uri.parse(_authUrl),
      body: {"api_key": _apiKey},
    );

    final data = jsonDecode(response.body);
    return data['token'];
  }

  // 2️⃣ Create Order
  static Future<int> createOrder(String token, int amount) async {
    final response = await http.post(
      Uri.parse(_orderUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "auth_token": token,
        "delivery_needed": false,
        "amount_cents": amount * 100,
        "currency": "EGP",
        "items": []
      }),
    );

    final data = jsonDecode(response.body);
    return data['id'];
  }

  // 3️⃣ Payment Key
  static Future<String> getPaymentKey(
      String token, int orderId, int amount) async {
    final response = await http.post(
      Uri.parse(_paymentKeyUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "auth_token": token,
        "amount_cents": amount * 100,
        "expiration": 3600,
        "order_id": orderId,
        "billing_data": {
          "first_name": "User",
          "last_name": "Test",
          "email": "test@test.com",
          "phone_number": "01000000000",
          "country": "EG"
        },
        "currency": "EGP",
        "integration_id": _integrationId
      }),
    );

    final data = jsonDecode(response.body);
    return data['token'];
  }

  // 4️⃣ Final Payment URL
  static String getPaymentUrl(String paymentToken) {
    return "https://accept.paymob.com/api/acceptance/iframes/YOUR_IFRAME_ID?payment_token=$paymentToken";
  }
}
