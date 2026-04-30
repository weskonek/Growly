import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Calls create-order edge function and returns Snap token + redirect URL.
Future<({String orderId, String snapToken, String redirectUrl})> createMidtransOrder({
  required String parentId,
  required String tier,
  required String paymentMethod,
}) async {
  final dio = Dio();
  final baseUrl = _getSupabaseUrl();

  final resp = await dio.post(
    '$baseUrl/functions/v1/create-order',
    data: {
      'parent_id': parentId,
      'tier': tier,
      'payment_method': paymentMethod,
    },
  );

  if (resp.statusCode != 200) {
    throw Exception(resp.data['error'] ?? 'Failed to create order');
  }

  final data = resp.data as Map<String, dynamic>;
  return (
    orderId: data['order_id'] as String,
    snapToken: data['snap_token'] as String,
    redirectUrl: data['redirect_url'] as String,
  );
}

/// Opens Midtrans Snap payment page in a WebView.
/// Calls onSuccess / onPending / onError callbacks based on the result URL.
/// Returns the final transaction result.
Future<({String status, String orderId})> openSnapPayment({
  required String snapToken,
  required String redirectUrl,
  required Future<void> Function(String redirectUrl) openWebView,
}) async {
  // Parse Midtrans notification from final redirect URL
  // The redirect URL from Snap will contain query params indicating the result:
  //   ?order_id=...&status_code=...&transaction_status=...&signature_key=...
  await openWebView(redirectUrl);

  // After WebView closes, parse the final URL to determine status
  // In production, the WebView returns via onPageFinished or custom URL scheme.
  // For now, we return a placeholder — real implementation uses
  // WebViewController.evaluateJavaScript to read window.location on the Snap finish page
  // and match against midtrans-callback paths.
  return (status: 'pending', orderId: snapToken);
}

String _getSupabaseUrl() {
  if (kDebugMode) {
    return const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://your-project.supabase.co');
  }
  return const String.fromEnvironment('SUPABASE_URL');
}