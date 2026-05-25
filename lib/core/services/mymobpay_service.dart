import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ── Payment Status & Result ──────────────────────────────────────
enum MyMobPayStatus { success, failed, cancelled, pending }

class MyMobPayResult {
  final MyMobPayStatus status;
  final String? orderId;
  final String? message;

  const MyMobPayResult({
    required this.status,
    this.orderId,
    this.message,
  });

  bool get isSuccess => status == MyMobPayStatus.success;

  factory MyMobPayResult.success({String? orderId}) =>
      MyMobPayResult(status: MyMobPayStatus.success, orderId: orderId);

  factory MyMobPayResult.failed(String msg) =>
      MyMobPayResult(status: MyMobPayStatus.failed, message: msg);

  factory MyMobPayResult.cancelled() =>
      const MyMobPayResult(status: MyMobPayStatus.cancelled, message: 'Payment cancelled.');

  factory MyMobPayResult.pending(String orderId) => MyMobPayResult(
      status: MyMobPayStatus.pending,
      orderId: orderId,
      message: 'Payment is pending verification.');
}

// ── MyMobPay Order Creation Response ──────────────────────────────
class MyMobPayOrderResponse {
  final bool success;
  final String? orderId;
  final String? orderAmount;
  final String? mode;
  final String? apiKey;
  final String? errorMessage;

  const MyMobPayOrderResponse({
    required this.success,
    this.orderId,
    this.orderAmount,
    this.mode,
    this.apiKey,
    this.errorMessage,
  });
}

// ── MyMobPay Service ────────────────────────────────────────────────
class MyMobPayService {
  // ── Environment Configuration ─────────────────────────────────────
  static String get apiKeyEnv => dotenv.env['MYMOBPAY_API_KEY'] ?? '';

  static bool get isConfigured =>
      apiKeyEnv.isNotEmpty &&
      apiKeyEnv != 'YOUR_MYMOBPAY_API_KEY';

  /// MyMobPay WebView checkout works on Android & iOS.
  static bool get isSupported => !kIsWeb;

  // ── Securely Create an Order (via Vercel Backend) ────────────────
  static Future<MyMobPayOrderResponse> generateOrder({
    required double amount,
    required String customerId,
    required String planName,
    String? customerPhone,
    String? customerName,
  }) async {
    try {
      debugPrint('MYMOBPAY: Calling Vercel backend to initialize order...');

      // Replace with your actual backend domain (using same domain as Paytm)
      const backendUrl = 'https://gainiq-ten.vercel.app/api/mymobpay';

      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount.toStringAsFixed(2),
          'customerId': customerId,
          'planName': planName,
          'customerPhone': customerPhone ?? '',
          'customerName': customerName ?? 'GainIQ Customer',
        }),
      ).timeout(const Duration(seconds: 30));

      debugPrint('MYMOBPAY: Vercel HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        final bodyJson = jsonDecode(response.body);
        final errorMsg = bodyJson['errorMessage'] ?? 'Server error';
        return MyMobPayOrderResponse(
          success: false,
          errorMessage: errorMsg,
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json['success'] == true) {
        debugPrint('MYMOBPAY: Order initialized successfully ✓');
        return MyMobPayOrderResponse(
          success: true,
          orderId: json['orderId'],
          orderAmount: json['orderAmount']?.toString(),
          mode: json['mode'],
          apiKey: json['apiKey'] ?? apiKeyEnv,
        );
      } else {
        return MyMobPayOrderResponse(
          success: false,
          errorMessage: json['errorMessage'] ?? 'Failed to initialize order.',
        );
      }
    } catch (e) {
      debugPrint('MYMOBPAY ERROR: $e');
      return const MyMobPayOrderResponse(
        success: false,
        errorMessage: 'Network error communicating with backend.',
      );
    }
  }

  // ── Poll / Get Order Status ───────────────────────────────────────
  /// Public endpoint: checks order status on mymob.tech without API keys
  static Future<String> getOrderStatus(String orderId) async {
    try {
      final url = 'https://mymob.tech/api/orders?id=$orderId';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'pending';
      }
    } catch (e) {
      debugPrint('MYMOBPAY: Status check error: $e');
    }
    return 'pending';
  }

  // ── Build Checkout Payment Page URL ──────────────────────────────
  static String buildPaymentUrl({
    required String orderId,
    required String amount,
    required String apiKey,
    String? callbackUrl,
  }) {
    final params = {
      'api_key': apiKey,
      'amount': amount,
      'project': 'GainIQ',
      'ref': orderId,
    };

    if (callbackUrl != null) {
      params['callback'] = callbackUrl;
    }

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://mymob.tech/pay?$query';
  }
}
