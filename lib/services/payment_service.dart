import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Lenco by Broadpay — Zambia payment gateway
/// Docs: https://docs.broadpay.io
///
/// Supports:
///   - MTN Mobile Money (mtn_momo)
///   - Airtel Money (airtel_money)
///   - Visa / Mastercard (card)
class LencoPaymentService {
  static String get _baseUrl =>
      dotenv.env['LENCO_BASE_URL'] ?? 'https://api.broadpay.io/v1';
  static String get _apiKey =>
      dotenv.env['LENCO_API_KEY'] ?? '';
  static String get _merchantId =>
      dotenv.env['LENCO_MERCHANT_ID'] ?? '';
  static String get _webhookSecret =>
      dotenv.env['LENCO_WEBHOOK_SECRET'] ?? '';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'X-Merchant-ID': _merchantId,
  };

  // ── Initiate mobile money payment ─────────────────────────
  /// [method] must be 'mtn_momo' or 'airtel_money'
  /// [phoneNumber] in format 260XXXXXXXXX (Zambian number without +)
  /// Returns a [PaymentResponse] with tx ID and status.
  static Future<PaymentResponse> initiateMobileMoney({
    required String invoiceNumber,
    required double amountZmw,
    required String method,
    required String phoneNumber,
    required String customerName,
    required String customerEmail,
  }) async {
    final body = {
      'merchant_reference': invoiceNumber,
      'amount': amountZmw.toStringAsFixed(2),
      'currency': 'ZMW',
      'payment_method': method,
      'mobile_number': phoneNumber.replaceAll(RegExp(r'[\s+]'), ''),
      'customer': {
        'name': customerName,
        'email': customerEmail,
      },
      'description': 'Magnum Security — Invoice $invoiceNumber',
      'callback_url': '${dotenv.env['APP_URL'] ?? ''}/payment/callback',
      'return_url': '${dotenv.env['APP_URL'] ?? ''}/client/billing',
    };

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/payments/mobile'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResponse(
          success: true,
          txId: data['transaction_id'] as String? ?? data['id'] as String? ?? '',
          status: data['status'] as String? ?? 'pending',
          message: data['message'] as String? ?? 'Payment initiated',
          ussdCode: data['ussd_code'] as String?,
          checkoutUrl: data['checkout_url'] as String?,
        );
      } else {
        return PaymentResponse(
          success: false,
          txId: '',
          status: 'failed',
          message: data['message'] as String? ?? 'Payment initiation failed',
        );
      }
    } catch (e) {
      debugPrint('Lenco mobile money error: $e');
      return PaymentResponse(
        success: false,
        txId: '',
        status: 'failed',
        message: 'Network error. Please try again.',
      );
    }
  }

  // ── Initiate card payment ─────────────────────────────────
  /// Returns a hosted checkout URL that opens in browser/WebView.
  static Future<PaymentResponse> initiateCardPayment({
    required String invoiceNumber,
    required double amountZmw,
    required String customerName,
    required String customerEmail,
  }) async {
    final body = {
      'merchant_reference': invoiceNumber,
      'amount': amountZmw.toStringAsFixed(2),
      'currency': 'ZMW',
      'payment_method': 'card',
      'customer': {
        'name': customerName,
        'email': customerEmail,
      },
      'description': 'Magnum Security — Invoice $invoiceNumber',
      'callback_url': '${dotenv.env['APP_URL'] ?? ''}/payment/callback',
      'return_url': '${dotenv.env['APP_URL'] ?? ''}/client/billing',
    };

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/payments/card'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentResponse(
          success: true,
          txId: data['transaction_id'] as String? ?? data['id'] as String? ?? '',
          status: data['status'] as String? ?? 'pending',
          message: 'Redirecting to checkout...',
          checkoutUrl: data['checkout_url'] as String?,
        );
      } else {
        return PaymentResponse(
          success: false,
          txId: '',
          status: 'failed',
          message: data['message'] as String? ?? 'Card payment initiation failed',
        );
      }
    } catch (e) {
      debugPrint('Lenco card payment error: $e');
      return PaymentResponse(
        success: false,
        txId: '',
        status: 'failed',
        message: 'Network error. Please try again.',
      );
    }
  }

  // ── Check payment status ──────────────────────────────────
  static Future<PaymentStatusResult> checkStatus(String txId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/payments/$txId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return PaymentStatusResult(
          txId: txId,
          status: data['status'] as String? ?? 'pending',
          message: data['message'] as String?,
          paidAt: data['paid_at'] != null
              ? DateTime.tryParse(data['paid_at'] as String)
              : null,
        );
      }
    } catch (e) {
      debugPrint('Lenco status check error: $e');
    }
    return PaymentStatusResult(txId: txId, status: 'unknown');
  }

  // ── Verify webhook signature ──────────────────────────────
  /// Call this in your Supabase Edge Function webhook handler.
  /// The signature is HMAC-SHA256 of the raw request body.
  static bool verifyWebhookSignature(String rawBody, String signature) {
    // This logic lives in the Edge Function (Deno), not the Flutter app.
    // Included here as documentation of the expected pattern.
    // See: supabase/functions/payment-webhook/index.ts
    return false; // placeholder
  }
}

// ── Result types ──────────────────────────────────────────────
class PaymentResponse {
  final bool success;
  final String txId;
  final String status;
  final String message;
  final String? ussdCode;       // MTN/Airtel USSD prompt code
  final String? checkoutUrl;    // Card hosted page URL

  const PaymentResponse({
    required this.success,
    required this.txId,
    required this.status,
    required this.message,
    this.ussdCode,
    this.checkoutUrl,
  });
}

class PaymentStatusResult {
  final String txId;
  final String status;
  final String? message;
  final DateTime? paidAt;

  const PaymentStatusResult({
    required this.txId,
    required this.status,
    this.message,
    this.paidAt,
  });

  bool get isCompleted => status == 'completed' || status == 'successful';
  bool get isFailed    => status == 'failed' || status == 'cancelled';
  bool get isPending   => !isCompleted && !isFailed;
}
