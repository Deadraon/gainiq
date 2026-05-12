import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/services/paytm_service.dart';

/// Full-screen Paytm hosted checkout using InAppWebView.
/// Returns [PaytmResult] when payment completes.
class PaytmWebViewScreen extends StatefulWidget {
  final String orderId;
  final String txnToken;
  final String amount;

  const PaytmWebViewScreen({
    super.key,
    required this.orderId,
    required this.txnToken,
    required this.amount,
  });

  @override
  State<PaytmWebViewScreen> createState() => _PaytmWebViewScreenState();
}

class _PaytmWebViewScreenState extends State<PaytmWebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  double _progress = 0;

  late final String _paymentUrl;

  @override
  void initState() {
    super.initState();
    _paymentUrl = PaytmService.buildPaymentUrl(
      orderId: widget.orderId,
      txnToken: widget.txnToken,
      amount: widget.amount,
    );
  }

  void _handleUrlChange(String url) {
    // Paytm calls back to the callback URL on completion
    if (url.contains('paytmCallback') || url.contains('ORDER_ID')) {
      _parseCallbackUrl(url);
    }
    // Handle cancellation pages
    if (url.contains('cancel') || url.contains('CANCEL')) {
      if (mounted) Navigator.of(context).pop(PaytmResult.cancelled());
    }
  }

  void _parseCallbackUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Check for transaction status in query params or in page load
      final status = uri.queryParameters['STATUS'] ??
          uri.queryParameters['status'] ?? '';
      final txnId = uri.queryParameters['TXNID'] ??
          uri.queryParameters['txnId'] ?? '';

      if (status.toUpperCase() == 'TXN_SUCCESS') {
        if (mounted) {
          Navigator.of(context)
              .pop(PaytmResult.success(txnId: txnId, orderId: widget.orderId));
        }
      } else if (status.toUpperCase() == 'TXN_FAILURE') {
        final msg = uri.queryParameters['RESPMSG'] ?? 'Payment failed';
        if (mounted) Navigator.of(context).pop(PaytmResult.failed(msg));
      } else if (status.toUpperCase() == 'PENDING') {
        if (mounted) {
          Navigator.of(context).pop(PaytmResult.pending(widget.orderId));
        }
      }
    } catch (_) {
      // URL not yet a callback — keep loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF002F6C), // Paytm navy
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Text('💳 ', style: TextStyle(fontSize: 18)),
            const Text(
              'Paytm Checkout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              Navigator.of(context).pop(PaytmResult.cancelled()),
        ),
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF00BAF2)),
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
            onWebViewCreated: (c) => _webViewController = c,
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
              if (mounted) {
                Navigator.of(context).pop(
                    PaytmResult.failed('Connection error: ${error.description}'));
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
                      color: Color(0xFF00BAF2),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Paytm...',
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
