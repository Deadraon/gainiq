import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/services/mymobpay_service.dart';

/// Full-screen MyMobPay checkout using InAppWebView with real-time status polling.
/// Returns [MyMobPayResult] when payment completes.
class MyMobPayWebViewScreen extends StatefulWidget {
  final String orderId;
  final String amount;
  final String apiKey;

  const MyMobPayWebViewScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.apiKey,
  });

  @override
  State<MyMobPayWebViewScreen> createState() => _MyMobPayWebViewScreenState();
}

class _MyMobPayWebViewScreenState extends State<MyMobPayWebViewScreen> {
  bool _isLoading = true;
  double _progress = 0;
  Timer? _statusPollingTimer;
  bool _isCheckingStatus = false;

  late final String _paymentUrl;
  static const String _callbackUrl = 'https://gainiq-ten.vercel.app/api/mymobpay-callback';

  @override
  void initState() {
    super.initState();
    _paymentUrl = MyMobPayService.buildPaymentUrl(
      orderId: widget.orderId,
      amount: widget.amount,
      apiKey: widget.apiKey,
      callbackUrl: _callbackUrl,
    );

    // Start background polling to check transaction status in real-time.
    // This handles cases where redirect fails or completes earlier.
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _statusPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;
    _isCheckingStatus = true;

    try {
      final status = await MyMobPayService.getOrderStatus(widget.orderId);
      if (!mounted) return;

      if (status == 'verified') {
        _statusPollingTimer?.cancel();
        Navigator.of(context).pop(
          MyMobPayResult.success(orderId: widget.orderId),
        );
      } else if (status == 'expired') {
        _statusPollingTimer?.cancel();
        Navigator.of(context).pop(
          MyMobPayResult.failed('Transaction expired. Please try again.'),
        );
      } else if (status == 'rejected') {
        _statusPollingTimer?.cancel();
        Navigator.of(context).pop(
          MyMobPayResult.failed('Transaction rejected by administrator.'),
        );
      }
    } catch (e) {
      debugPrint('Error during background status check: $e');
    } finally {
      _isCheckingStatus = false;
    }
  }

  void _handleUrlChange(String url) {
    debugPrint('MYMOBPAY WEBVIEW URL: $url');
    // If we land on the callback URL or callback query param, verify status immediately.
    if (url.contains('mymobpay-callback') || url.contains('order_id=')) {
      _checkPaymentStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A), // Blue/indigo branding
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('⚡ ', style: TextStyle(fontSize: 18)),
            const Text(
              'UPI Secure Checkout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              Navigator.of(context).pop(MyMobPayResult.cancelled()),
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFE5FF00)),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_paymentUrl),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              useHybridComposition: true,
              useShouldOverrideUrlLoading: true,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onLoadStart: (c, url) {
              setState(() => _isLoading = true);
              if (url != null) _handleUrlChange(url.toString());
            },
            onLoadStop: (c, url) {
              setState(() => _isLoading = false);
              if (url != null) _handleUrlChange(url.toString());
            },
            onProgressChanged: (c, progress) {
              setState(() => _progress = progress / 100.0);
            },
            shouldOverrideUrlLoading: (c, action) async {
              final url = action.request.url?.toString() ?? '';
              _handleUrlChange(url);
              return NavigationActionPolicy.ALLOW;
            },
            onReceivedError: (c, request, error) {
              // Ignore standard localized cancellations/crashes
              if (error.description.contains('net::ERR_ABORTED')) return;
              
              if (mounted) {
                Navigator.of(context).pop(
                  MyMobPayResult.failed('Connection error: ${error.description}'),
                );
              }
            },
          ),

          // Initial loading overlay
          if (_isLoading && _progress == 0)
            Container(
              color: const Color(0xFF0A0A0A),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFE5FF00),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Payment Page...',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
