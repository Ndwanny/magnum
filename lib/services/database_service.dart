import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guard.dart';
import '../models/incident.dart';
import '../models/client_site.dart';
import '../models/invoice.dart';
import '../models/patrol_log.dart';
import '../models/attendance.dart';
import '../models/payroll.dart';
import '../models/crm_lead.dart';

/// Wraps all Supabase queries.  Drop-in replacement for MockDataService.
class DatabaseService {
  static SupabaseClient get _sb => Supabase.instance.client;

  // ── Guards ────────────────────────────────────────────────
  static Future<List<Guard>> fetchGuards() async {
    final rows = await _sb.from('guards').select().order('name');
    return rows.map(_rowToGuard).toList();
  }

  static Future<Guard?> fetchGuardByUserId(String userId) async {
    final rows = await _sb
        .from('guards')
        .select()
        .eq('user_id', userId)
        .limit(1);
    if (rows.isEmpty) return null;
    return _rowToGuard(rows.first);
  }

  // ── Incidents ─────────────────────────────────────────────
  static Future<List<Incident>> fetchIncidents({String? siteId}) async {
    if (siteId != null) {
      final rows = await _sb.from('incidents').select().eq('site_id', siteId).order('created_at', ascending: false);
      return rows.map<Incident>(_rowToIncident).toList();
    }
    final rows = await _sb.from('incidents').select().order('created_at', ascending: false);
    return rows.map<Incident>(_rowToIncident).toList();
  }

  static Future<void> createIncident({
    required String title,
    required String description,
    required String severity,
    required String siteId,
    required String reportedBy,
    required String reportedById,
  }) async {
    await _sb.from('incidents').insert({
      'title': title,
      'description': description,
      'severity': severity,
      'site_id': siteId,
      'reported_by': reportedBy,
      'reported_by_id': reportedById,
      'status': 'Open',
    });
  }

  static Future<void> updateIncidentStatus(String incidentId, String status, {String? resolvedBy}) async {
    await _sb.from('incidents').update({
      'status': status,
      if (resolvedBy != null) 'resolved_by': resolvedBy,
      if (status == 'Resolved' || status == 'Closed') 'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', incidentId);
  }

  // ── Client Sites ──────────────────────────────────────────
  static Future<List<ClientSite>> fetchSites({String? clientUserId}) async {
    if (clientUserId != null) {
      final rows = await _sb.from('client_sites').select().eq('client_user_id', clientUserId).order('name');
      return rows.map<ClientSite>(_rowToClientSite).toList();
    }
    final rows = await _sb.from('client_sites').select().order('name');
    return rows.map<ClientSite>(_rowToClientSite).toList();
  }

  // ── Patrol Logs ───────────────────────────────────────────
  static Future<List<PatrolLog>> fetchPatrolLogs({String? guardId, String? siteId}) async {
    var q = _sb.from('patrol_logs').select('*, patrol_checkpoints(*)');
    if (guardId != null) q = q.eq('guard_id', guardId);
    if (siteId != null)  q = q.eq('site_id', siteId);
    final rows = await q.order('start_time', ascending: false);
    return rows.map<PatrolLog>(_rowToPatrolLog).toList();
  }

  static Future<String> startPatrol({
    required String guardId,
    required String guardName,
    required String guardBadge,
    required String siteId,
    required String siteName,
  }) async {
    final row = await _sb.from('patrol_logs').insert({
      'guard_id': guardId,
      'guard_name': guardName,
      'guard_badge': guardBadge,
      'site_id': siteId,
      'site_name': siteName,
      'start_time': DateTime.now().toIso8601String(),
      'status': 'Ongoing',
    }).select().single();
    return row['id'] as String;
  }

  static Future<void> scanCheckpoint({
    required String patrolLogId,
    required String checkpointName,
    bool isOk = true,
    String? notes,
  }) async {
    await _sb.from('patrol_checkpoints').insert({
      'patrol_log_id': patrolLogId,
      'checkpoint_name': checkpointName,
      'is_ok': isOk,
      'notes': notes,
    });
  }

  static Future<void> completePatrol(String patrolLogId) async {
    await _sb.from('patrol_logs').update({
      'end_time': DateTime.now().toIso8601String(),
      'status': 'Completed',
    }).eq('id', patrolLogId);
  }

  // ── Attendance ────────────────────────────────────────────
  static Future<List<AttendanceRecord>> fetchAttendance({String? guardId}) async {
    var query = _sb.from('attendance_records').select();
    if (guardId != null) {
      final rows = await query.eq('guard_id', guardId).order('date', ascending: false);
      return rows.map<AttendanceRecord>(_rowToAttendance).toList();
    }
    final rows = await query.order('date', ascending: false);
    return rows.map<AttendanceRecord>(_rowToAttendance).toList();
  }

  static Future<String> clockIn({
    required String guardId,
    required String guardName,
    required String guardBadge,
    required String siteId,
    required String siteName,
    required String shiftType,
  }) async {
    final row = await _sb.from('attendance_records').insert({
      'guard_id': guardId,
      'guard_name': guardName,
      'guard_badge': guardBadge,
      'site_id': siteId,
      'site_name': siteName,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'clock_in': DateTime.now().toIso8601String(),
      'shift_type': shiftType,
      'status': 'Present',
    }).select().single();
    return row['id'] as String;
  }

  static Future<void> clockOut(String attendanceId) async {
    await _sb.from('attendance_records').update({
      'clock_out': DateTime.now().toIso8601String(),
    }).eq('id', attendanceId);
  }

  // ── Invoices ──────────────────────────────────────────────
  static Future<List<Invoice>> fetchInvoices({String? clientUserId}) async {
    if (clientUserId != null) {
      final rows = await _sb.from('invoices').select('*, invoice_items(*)').eq('client_user_id', clientUserId).order('issued_date', ascending: false);
      return rows.map<Invoice>(_rowToInvoice).toList();
    }
    final rows = await _sb.from('invoices').select('*, invoice_items(*)').order('issued_date', ascending: false);
    return rows.map<Invoice>(_rowToInvoice).toList();
  }

  static Future<void> markInvoicePaid(String invoiceId, {
    required String paymentRef,
    required String method,
    String? lencoTxId,
  }) async {
    await _sb.from('invoices').update({
      'status': 'Paid',
      'payment_ref': paymentRef,
      'payment_method': method,
      'paid_at': DateTime.now().toIso8601String(),
      if (lencoTxId != null) 'lenco_tx_id': lencoTxId,
    }).eq('id', invoiceId);
  }

  // ── Payroll ───────────────────────────────────────────────
  static Future<List<PayrollRecord>> fetchPayroll({String? guardId}) async {
    if (guardId != null) {
      final rows = await _sb.from('payroll_records').select().eq('guard_id', guardId).order('created_at', ascending: false);
      return rows.map<PayrollRecord>(_rowToPayroll).toList();
    }
    final rows = await _sb.from('payroll_records').select().order('created_at', ascending: false);
    return rows.map<PayrollRecord>(_rowToPayroll).toList();
  }

  // ── Leads (CRM) ───────────────────────────────────────────
  static Future<List<CrmLead>> fetchLeads() async {
    final rows = await _sb.from('leads').select().order('created_at', ascending: false);
    return rows.map<CrmLead>(_rowToLead).toList();
  }

  static Future<void> updateLeadStage(String leadId, String stage) async {
    await _sb.from('leads').update({
      'stage': stage,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', leadId);
  }

  // ── Contact / Quote submissions ───────────────────────────
  static Future<void> submitContact({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    await _sb.from('contact_submissions').insert({
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
    });
  }

  static Future<void> submitQuote({
    required String name,
    required String company,
    required String email,
    required String phone,
    required String serviceType,
    required int guardsNeeded,
    required String siteAddress,
    String? notes,
  }) async {
    await _sb.from('quote_submissions').insert({
      'name': name,
      'company': company,
      'email': email,
      'phone': phone,
      'service_type': serviceType,
      'guards_needed': guardsNeeded,
      'site_address': siteAddress,
      'notes': notes,
    });
  }

  // ── Payment Transactions ──────────────────────────────────
  static Future<String> createPaymentTransaction({
    required String invoiceId,
    required double amount,
    required String method,
    String? phoneNumber,
  }) async {
    final row = await _sb.from('payment_transactions').insert({
      'invoice_id': invoiceId,
      'amount': amount,
      'currency': 'ZMW',
      'method': method,
      'status': 'pending',
      if (phoneNumber != null) 'phone_number': phoneNumber,
    }).select().single();
    return row['id'] as String;
  }

  static Future<void> updatePaymentTransaction(String txId, {
    required String status,
    String? lencoTxId,
    String? failureReason,
    Map<String, dynamic>? webhookPayload,
  }) async {
    await _sb.from('payment_transactions').update({
      'status': status,
      if (lencoTxId != null) 'lenco_tx_id': lencoTxId,
      if (failureReason != null) 'failure_reason': failureReason,
      if (webhookPayload != null) 'webhook_payload': webhookPayload,
      if (status == 'completed') 'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', txId);
  }

  // ── Mappers ───────────────────────────────────────────────
  static Guard _rowToGuard(Map<String, dynamic> r) => Guard(
    id: r['id'] as String,
    name: r['name'] as String,
    badgeNumber: r['badge_number'] as String,
    phone: r['phone'] as String? ?? '',
    email: r['email'] as String? ?? '',
    role: r['role'] as String? ?? 'Unarmed',
    status: r['status'] as String? ?? 'Active',
    currentSite: r['current_site'] as String? ?? '-',
    joinDate: r['join_date'] as String? ?? '',
    photoUrl: r['photo_url'] as String? ?? '',
    certifications: (r['certifications'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  static Incident _rowToIncident(Map<String, dynamic> r) => Incident(
    id: r['id'] as String,
    title: r['title'] as String,
    description: r['description'] as String? ?? '',
    severity: r['severity'] as String? ?? 'Low',
    status: r['status'] as String? ?? 'Open',
    site: r['site_name'] as String? ?? '',
    reportedBy: r['reported_by'] as String? ?? '',
    reportedAt: DateTime.parse(r['created_at'] as String),
    resolvedBy: r['resolved_by'] as String?,
    resolvedAt: r['resolved_at'] != null ? DateTime.parse(r['resolved_at'] as String) : null,
  );

  static ClientSite _rowToClientSite(Map<String, dynamic> r) => ClientSite(
    id: r['id'] as String,
    name: r['name'] as String,
    address: r['address'] as String? ?? '',
    clientName: r['client_name'] as String,
    guardsDeployed: r['guards_deployed'] as int? ?? 0,
    serviceType: r['service_type'] as String? ?? '',
    status: r['status'] as String? ?? 'Active',
    contractEnd: r['contract_end'] as String? ?? '',
  );

  static PatrolLog _rowToPatrolLog(Map<String, dynamic> r) {
    final cps = (r['patrol_checkpoints'] as List<dynamic>? ?? [])
        .map((c) => CheckpointEntry(
              checkpointName: c['checkpoint_name'] as String,
              scannedAt: DateTime.parse(c['scanned_at'] as String),
              isOk: c['is_ok'] as bool? ?? true,
            ))
        .toList();
    return PatrolLog(
      id: r['id'] as String,
      guardName: r['guard_name'] as String? ?? '',
      guardBadge: r['guard_badge'] as String? ?? '',
      site: r['site_name'] as String? ?? '',
      startTime: DateTime.parse(r['start_time'] as String),
      endTime: r['end_time'] != null ? DateTime.parse(r['end_time'] as String) : null,
      checkpoints: cps,
      notes: r['notes'] as String? ?? '',
      status: r['status'] as String? ?? 'Ongoing',
    );
  }

  static AttendanceRecord _rowToAttendance(Map<String, dynamic> r) => AttendanceRecord(
    id: r['id'] as String,
    guardId: r['guard_id'] as String,
    guardName: r['guard_name'] as String? ?? '',
    guardBadge: r['guard_badge'] as String? ?? '',
    site: r['site_name'] as String? ?? '',
    date: DateTime.parse(r['date'] as String),
    clockIn: r['clock_in'] != null ? DateTime.parse(r['clock_in'] as String) : null,
    clockOut: r['clock_out'] != null ? DateTime.parse(r['clock_out'] as String) : null,
    status: r['status'] as String? ?? 'Present',
    notes: r['notes'] as String?,
  );

  static Invoice _rowToInvoice(Map<String, dynamic> r) {
    final items = (r['invoice_items'] as List<dynamic>? ?? [])
        .map((i) => InvoiceItem(
              description: i['description'] as String,
              quantity: i['quantity'] as int? ?? 1,
              unitPrice: (i['unit_price'] as num).toDouble(),
            ))
        .toList();
    return Invoice(
      id: r['id'] as String,
      invoiceNumber: r['invoice_number'] as String,
      clientName: r['client_name'] as String,
      amount: (r['amount'] as num).toDouble(),
      currency: r['currency'] as String? ?? 'ZMW',
      status: r['status'] as String? ?? 'Pending',
      issuedDate: DateTime.parse(r['issued_date'] as String),
      dueDate: DateTime.parse(r['due_date'] as String),
      items: items,
    );
  }

  static PayrollRecord _rowToPayroll(Map<String, dynamic> r) => PayrollRecord(
    id: r['id'] as String,
    guardId: r['guard_id'] as String,
    guardName: r['guard_name'] as String? ?? '',
    period: r['period'] as String,
    basicPay: (r['basic_pay'] as num).toDouble(),
    allowances: (r['allowances'] as num).toDouble(),
    overtime: (r['overtime'] as num).toDouble(),
    napsa: (r['napsa'] as num).toDouble(),
    nhima: (r['nhima'] as num? ?? 0).toDouble(),
    paye: (r['paye'] as num).toDouble(),
    status: r['status'] as String? ?? 'Pending',
    paidAt: r['paid_at'] != null ? DateTime.parse(r['paid_at'] as String) : null,
  );

  static CrmLead _rowToLead(Map<String, dynamic> r) => CrmLead(
    id: r['id'] as String,
    companyName: r['company_name'] as String,
    contactName: r['contact_name'] as String? ?? '',
    phone: r['phone'] as String? ?? '',
    email: r['email'] as String? ?? '',
    serviceInterest: r['service_interest'] as String? ?? '',
    stage: r['stage'] as String? ?? 'New',
    quotedValue: r['quoted_value'] != null ? (r['quoted_value'] as num).toDouble() : null,
    createdAt: DateTime.parse(r['created_at'] as String),
    followUpDate: r['follow_up_date'] != null ? DateTime.parse(r['follow_up_date'] as String) : null,
    notes: r['notes'] as String? ?? '',
  );
}
