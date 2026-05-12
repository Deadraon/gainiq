import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ── Payment Result ────────────────────────────────────────────────
enum PaytmStatus { success, failed, cancelled, pending }

class PaytmResult {
  final PaytmStatus status;
  final String? txnId;
  final String? orderId;
  final String? message;

  const PaytmResult({
    required this.status,
    this.txnId,
    this.orderId,
    this.message,
  });

  bool get isSuccess => status == PaytmStatus.success;

  factory PaytmResult.success({String? txnId, String? orderId}) =>
      PaytmResult(status: PaytmStatus.success, txnId: txnId, orderId: orderId);

  factory PaytmResult.failed(String msg) =>
      PaytmResult(status: PaytmStatus.failed, message: msg);

  factory PaytmResult.cancelled() =>
      const PaytmResult(status: PaytmStatus.cancelled, message: 'Payment cancelled.');

  factory PaytmResult.pending(String orderId) => PaytmResult(
      status: PaytmStatus.pending,
      orderId: orderId,
      message: 'Payment is pending verification.');
}

// ── Paytm Transaction Token Response ────────────────────────────
class PaytmTxnTokenResponse {
  final bool success;
  final String? txnToken;
  final String? orderId;
  final String? amount;
  final String? mid;
  final String? errorMessage;

  const PaytmTxnTokenResponse({
    required this.success,
    this.txnToken,
    this.orderId,
    this.amount,
    this.mid,
    this.errorMessage,
  });
}

// ── Paytm Service ─────────────────────────────────────────────────
class PaytmService {
  // ── Credentials ──────────────────────────────────────────────
  static String get mid => dotenv.env['PAYTM_MID'] ?? '';
  static String get merchantKey => dotenv.env['PAYTM_MERCHANT_KEY'] ?? '';
  static String get website => dotenv.env['PAYTM_WEBSITE'] ?? 'WEBSTAGING';
  static String get industryType =>
      dotenv.env['PAYTM_INDUSTRY_TYPE'] ?? 'Retail';

  static bool get isTest => website == 'WEBSTAGING';

  static String get baseUrl =>
      isTest ? 'https://securegw-stage.paytm.in' : 'https://securegw.paytm.in';

  static bool get isConfigured =>
      mid.isNotEmpty &&
      merchantKey.isNotEmpty &&
      mid != 'YOUR_PAYTM_MID_HERE';

  // ── Platform check ────────────────────────────────────────────
  /// Paytm WebView checkout only works on Android/iOS, not Flutter Web.
  static bool get isSupported => !kIsWeb;

  // ── Generate Transaction Token ────────────────────────────────
  /// Calls Paytm staging API to get a txnToken.
  static Future<PaytmTxnTokenResponse> generateTxnToken({
    required double amount,
    required String customerId,
    String? orderId,
  }) async {
    if (!isConfigured) {
      return const PaytmTxnTokenResponse(
        success: false,
        errorMessage: 'Paytm not configured. Check your .env credentials.',
      );
    }

    if (!isSupported) {
      return const PaytmTxnTokenResponse(
        success: false,
        errorMessage:
            'Paytm payments are only supported on Android & iOS devices.',
      );
    }

    final order = orderId ?? _generateOrderId();
    final amountStr = amount.toStringAsFixed(2);

    try {
      // ── Build body ──────────────────────────────────────────
      final body = <String, dynamic>{
        'requestType': 'Payment',
        'mid': mid,
        'websiteName': website,
        'orderId': order,
        'callbackUrl': '$baseUrl/theia/paytmCallback?ORDER_ID=$order',
        'txnAmount': {'value': amountStr, 'currency': 'INR'},
        'userInfo': {'custId': customerId},
      };

      // ── Signature: HMAC-SHA256 of JSON body string ─────────
      // Paytm v1 API: sign the full body JSON (no salt, no pipe-sep)
      final signature = _signBody(body);

      final payload = jsonEncode({
        'body': body,
        'head': {'signature': signature},
      });

      debugPrint('PAYTM: Initiating transaction for order $order');
      debugPrint('PAYTM: MID=$mid | isTest=$isTest');

      final uri = Uri.parse(
          '$baseUrl/theia/api/v1/initiateTransaction?mid=$mid&orderId=$order');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('PAYTM: HTTP ${response.statusCode}');

      if (response.statusCode != 200) {
        return PaytmTxnTokenResponse(
          success: false,
          errorMessage:
              'Paytm server error (${response.statusCode}). Try again.',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final resultInfo = json['body']?['resultInfo'] as Map<String, dynamic>?;
      final resultCode = resultInfo?['resultCode']?.toString() ?? '';
      final resultMsg = resultInfo?['resultMsg']?.toString() ?? 'Unknown error';
      final txnToken = json['body']?['txnToken']?.toString();

      debugPrint('PAYTM: resultCode=$resultCode msg=$resultMsg');

      if (resultCode == '0000' && txnToken != null) {
        debugPrint('PAYTM: Token acquired ✓');
        return PaytmTxnTokenResponse(
          success: true,
          txnToken: txnToken,
          orderId: order,
          amount: amountStr,
          mid: mid,
        );
      } else {
        return PaytmTxnTokenResponse(
          success: false,
          errorMessage: 'Paytm: $resultMsg (code: $resultCode)',
        );
      }
    } catch (e) {
      debugPrint('PAYTM ERROR: $e');
      return PaytmTxnTokenResponse(
        success: false,
        errorMessage: 'Network error. Check your internet connection.',
      );
    }
  }

  // ── Build Hosted Checkout URL ─────────────────────────────────
  static String buildPaymentUrl({
    required String orderId,
    required String txnToken,
    required String amount,
  }) {
    final params = {
      'mid': mid,
      'orderId': orderId,
      'txnToken': txnToken,
      'amount': amount,
      'isWebView': '1',
    };
    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl/theia/api/v1/showPaymentPage?$query';
  }

  // ── Signature Generation ──────────────────────────────────────
  /// Paytm v1 API: HMAC-SHA256 of the full body JSON string.
  /// Reference: https://developer.paytm.com/docs/initiate-transaction-api/
  static String _signBody(Map<String, dynamic> body) {
    final bodyJson = jsonEncode(body);
    final hmacKey = utf8.encode(merchantKey);
    final hmac = Hmac(sha256, hmacKey);
    final digest = hmac.convert(utf8.encode(bodyJson));
    return digest.toString();
  }

  // ── Utilities ─────────────────────────────────────────────────
  static String _generateOrderId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random.secure().nextInt(99999).toString().padLeft(5, '0');
    return 'GAINIQ${ts}_$rand';
  }
}
