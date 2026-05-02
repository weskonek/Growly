import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaymentResult { success, pending, cancelled }

class SnapWebViewPage extends StatefulWidget {
  final String url;
  final String orderId;

  const SnapWebViewPage({
    super.key,
    required this.url,
    required this.orderId,
  });

  @override
  State<SnapWebViewPage> createState() => _SnapWebViewPageState();
}

class _SnapWebViewPageState extends State<SnapWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resultReturned = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _onPageStarted(String url) {
    _checkUrlForResult(url);
  }

  void _onPageFinished(String url) {
    if (mounted) {
      setState(() => _isLoading = false);
    }
    _checkUrlForResult(url);
  }

  void _onWebResourceError(WebResourceError error) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = 'Gagal memuat halaman pembayaran.';
    });
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url;
    // Intercept Snap finish/redirect URLs
    if (url.contains('transaction_status') ||
        url.contains('order_id') ||
        url.contains('status_code')) {
      _checkUrlForResult(url);
      return NavigationDecision.prevent;
    }
    // Allow all other navigations
    return NavigationDecision.navigate;
  }

  void _checkUrlForResult(String url) {
    if (!mounted) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final statusCode = uri.queryParameters['status_code'];
    final transactionStatus = uri.queryParameters['transaction_status'];

    // Determine result from Midtrans redirect params
    if (transactionStatus == null && statusCode == null) return;

    if (transactionStatus == 'settlement' || transactionStatus == 'capture') {
      _finishWith(PaymentResult.success);
    } else if (transactionStatus == 'pending') {
      _finishWith(PaymentResult.pending);
    } else if (transactionStatus == 'deny' ||
        transactionStatus == 'expire' ||
        transactionStatus == 'cancel') {
      _finishWith(PaymentResult.cancelled);
    } else if (statusCode == '200' && transactionStatus == null) {
      // Some Snap finish pages redirect back to app without transaction_status
      _finishWith(PaymentResult.success);
    }
  }

  void _finishWith(PaymentResult result) {
    if (!mounted || _resultReturned) return;
    _resultReturned = true;
    setState(() => _isLoading = false);
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finishWith(PaymentResult.cancelled),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _controller.reload(),
                      child: const Text('Coba Lagi'),
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
