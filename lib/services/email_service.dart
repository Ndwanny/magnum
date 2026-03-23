import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Calls Supabase Edge Functions to send transactional emails.
/// The Edge Functions use Resend (resend.com) as the email transport.
class EmailService {
  static SupabaseClient get _sb => Supabase.instance.client;

  // ── Contact form email ────────────────────────────────────
  /// Sends an internal notification to Magnum Security ops team
  /// and a confirmation to the customer.
  static Future<bool> sendContactNotification({
    required String fromName,
    required String fromEmail,
    required String phone,
    required String message,
  }) async {
    return _invoke('send-email', {
      'template': 'contact_notification',
      'to': 'info@magnumsecurity.co.zm',
      'data': {
        'from_name': fromName,
        'from_email': fromEmail,
        'phone': phone,
        'message': message,
        'submitted_at': DateTime.now().toIso8601String(),
      },
    });
  }

  // ── Quote request email ───────────────────────────────────
  static Future<bool> sendQuoteNotification({
    required String name,
    required String company,
    required String email,
    required String phone,
    required String serviceType,
    required int guardsNeeded,
    required String siteAddress,
    String? notes,
  }) async {
    // Notify internal team
    final internal = await _invoke('send-email', {
      'template': 'quote_notification',
      'to': 'sales@magnumsecurity.co.zm',
      'data': {
        'name': name,
        'company': company,
        'email': email,
        'phone': phone,
        'service_type': serviceType,
        'guards_needed': guardsNeeded,
        'site_address': siteAddress,
        'notes': notes ?? '',
      },
    });

    // Send acknowledgement to customer
    await _invoke('send-email', {
      'template': 'quote_confirmation',
      'to': email,
      'data': {
        'name': name,
        'company': company,
        'service_type': serviceType,
      },
    });

    return internal;
  }

  // ── Invoice email ─────────────────────────────────────────
  static Future<bool> sendInvoice({
    required String clientEmail,
    required String clientName,
    required String invoiceNumber,
    required double amount,
    required String dueDate,
  }) async {
    return _invoke('send-email', {
      'template': 'invoice',
      'to': clientEmail,
      'data': {
        'client_name': clientName,
        'invoice_number': invoiceNumber,
        'amount': amount.toStringAsFixed(2),
        'due_date': dueDate,
        'portal_url': 'https://portal.magnumsecurity.co.zm/client/billing',
      },
    });
  }

  // ── Invoice overdue reminder ──────────────────────────────
  static Future<bool> sendOverdueReminder({
    required String clientEmail,
    required String clientName,
    required String invoiceNumber,
    required double amount,
    required int daysOverdue,
  }) async {
    return _invoke('send-email', {
      'template': 'invoice_overdue',
      'to': clientEmail,
      'data': {
        'client_name': clientName,
        'invoice_number': invoiceNumber,
        'amount': amount.toStringAsFixed(2),
        'days_overdue': daysOverdue,
        'payment_url': 'https://portal.magnumsecurity.co.zm/client/billing',
        'support_email': 'billing@magnumsecurity.co.zm',
        'support_phone': '+260 977 123 456',
      },
    });
  }

  // ── Payment confirmation ──────────────────────────────────
  static Future<bool> sendPaymentConfirmation({
    required String clientEmail,
    required String clientName,
    required String invoiceNumber,
    required double amount,
    required String paymentMethod,
    required String txRef,
  }) async {
    return _invoke('send-email', {
      'template': 'payment_confirmation',
      'to': clientEmail,
      'data': {
        'client_name': clientName,
        'invoice_number': invoiceNumber,
        'amount': amount.toStringAsFixed(2),
        'payment_method': paymentMethod,
        'tx_ref': txRef,
        'paid_at': DateTime.now().toIso8601String(),
      },
    });
  }

  // ── Incident alert ────────────────────────────────────────
  static Future<bool> sendIncidentAlert({
    required String clientEmail,
    required String clientName,
    required String siteName,
    required String incidentTitle,
    required String severity,
    required String respondingGuard,
  }) async {
    return _invoke('send-email', {
      'template': 'incident_alert',
      'to': clientEmail,
      'data': {
        'client_name': clientName,
        'site_name': siteName,
        'incident_title': incidentTitle,
        'severity': severity,
        'responding_guard': respondingGuard,
        'reported_at': DateTime.now().toIso8601String(),
        'portal_url': 'https://portal.magnumsecurity.co.zm/client/incidents',
      },
    });
  }

  // ── Internal helper ───────────────────────────────────────
  static Future<bool> _invoke(String functionName, Map<String, dynamic> body) async {
    try {
      await _sb.functions.invoke(
        functionName,
        body: body,
      );
      return true;
    } catch (e) {
      debugPrint('EmailService error ($functionName): $e');
      return false;
    }
  }
}
