import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminPayrollScreen extends StatefulWidget {
  const AdminPayrollScreen({super.key});
  @override
  State<AdminPayrollScreen> createState() => _AdminPayrollScreenState();
}

class _AdminPayrollScreenState extends State<AdminPayrollScreen> {
  String _period = 'March 2024';
  final _periods = ['March 2024', 'February 2024', 'January 2024'];
  final fmt = NumberFormat('#,##0.00', 'en_US');

  Color _statusColor(String s) {
    switch (s) {
      case 'Paid':        return AppColors.success;
      case 'Processing':  return AppColors.info;
      case 'Pending':     return AppColors.warning;
      default:            return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final records = MockDataExt.payroll.where((r) => r.period == _period).toList();

    double totalGross = records.fold(0.0, (a, r) => a + r.grossPay);
    double totalNet   = records.fold(0.0, (a, r) => a + r.netPay);
    double totalDed   = records.fold(0.0, (a, r) => a + r.deductions);
    double totalNapsa = records.fold(0.0, (a, r) => a + r.napsa);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(children: [
        if (isDesktop) const AdminSidebar(),
        Expanded(child: Column(children: [
          const AdminTopBar(title: 'Payroll Management'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Payroll Management', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('ZMW payroll with NAPSA, NHIMA & PAYE deductions', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ]),
                Row(children: [
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      value: _period,
                      dropdownColor: AppColors.surface,
                      decoration: const InputDecoration(labelText: 'Period', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                      items: _periods.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _period = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showRunPayrollDialog(context),
                    icon: const Icon(Icons.payments, size: 16),
                    label: const Text('Run Payroll'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                  ),
                ]),
              ]),
              const SizedBox(height: 24),

              // Summary cards
              LayoutBuilder(builder: (ctx, c) {
                final cols = c.maxWidth > 700 ? 4 : 2;
                return Wrap(spacing: 16, runSpacing: 16, children: [
                  SizedBox(width: (c.maxWidth-(cols-1)*16)/cols, child: _PaySummaryCard(label: 'Total Gross Pay', value: 'ZMW ${fmt.format(totalGross)}', icon: Icons.account_balance_wallet, color: AppColors.primary)),
                  SizedBox(width: (c.maxWidth-(cols-1)*16)/cols, child: _PaySummaryCard(label: 'Total Deductions', value: 'ZMW ${fmt.format(totalDed)}', icon: Icons.remove_circle_outline, color: AppColors.warning)),
                  SizedBox(width: (c.maxWidth-(cols-1)*16)/cols, child: _PaySummaryCard(label: 'Total Net Pay', value: 'ZMW ${fmt.format(totalNet)}', icon: Icons.payments, color: AppColors.success)),
                  SizedBox(width: (c.maxWidth-(cols-1)*16)/cols, child: _PaySummaryCard(label: 'NAPSA Contribution', value: 'ZMW ${fmt.format(totalNapsa * 2)}', icon: Icons.security, color: AppColors.info)),
                ]);
              }),
              const SizedBox(height: 12),

              // ZRA compliance notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(children: const [
                  Icon(Icons.verified, color: AppColors.primary, size: 15),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                    'ZRA Compliant — PAYE calculated per 2024 Zambia Income Tax bands. NAPSA: 5% employee + 5% employer. NHIMA: 1% employee. All figures in ZMW.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  )),
                ]),
              ),
              const SizedBox(height: 20),

              // Payslip cards
              ...records.map((r) => _PayslipCard(record: r, fmt: fmt, statusColor: _statusColor(r.status))),

              // PAYE bands reference
              const SizedBox(height: 32),
              const Text('ZRA PAYE Tax Bands — 2024', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _TaxBandsTable(),
            ]),
          )),
        ])),
      ]),
    );
  }

  void _showRunPayrollDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Run Payroll — March 2024', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('This will process payroll for all active guards for March 2024. Payments will be initiated via:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          _PaymentMethodRow(icon: Icons.account_balance, label: 'Bank Transfer (Zanaco / Stanbic)', selected: true),
          _PaymentMethodRow(icon: Icons.phone_android, label: 'MTN Mobile Money', selected: false),
          _PaymentMethodRow(icon: Icons.phone_android, label: 'Airtel Money', selected: false),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: Row(children: const [
              Icon(Icons.warning_amber, color: AppColors.warning, size: 15),
              SizedBox(width: 8),
              Expanded(child: Text('This action cannot be undone. Ensure all attendance records are finalised.', style: TextStyle(color: AppColors.warning, fontSize: 12))),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payroll processing initiated for March 2024'), backgroundColor: AppColors.success));
            },
            child: const Text('Confirm & Process'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _PaymentMethodRow({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: 16),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(color: selected ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13)),
      const Spacer(),
      if (selected) const Icon(Icons.check_circle, color: AppColors.primary, size: 15),
    ]),
  );
}

class _PaySummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _PaySummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _PayslipCard extends StatefulWidget {
  final dynamic record;
  final NumberFormat fmt;
  final Color statusColor;
  const _PayslipCard({required this.record, required this.fmt, required this.statusColor});
  @override
  State<_PayslipCard> createState() => _PayslipCardState();
}

class _PayslipCardState extends State<_PayslipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final fmt = widget.fmt;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(r.guardName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.guardName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${r.period}  •  ID: ${r.guardId}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('ZMW ${fmt.format(r.netPay)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: widget.statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(r.status, style: TextStyle(color: widget.statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted, size: 20),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(color: AppColors.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('EARNINGS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              _PayRow('Basic Pay', r.basicPay, fmt, AppColors.textSecondary),
              _PayRow('Overtime', r.overtime, fmt, AppColors.textSecondary),
              _PayRow('Allowances', r.allowances, fmt, AppColors.textSecondary),
              _PayRow('Gross Pay', r.grossPay, fmt, AppColors.textPrimary, bold: true),
              const SizedBox(height: 16),
              const Text('STATUTORY DEDUCTIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              const SizedBox(height: 10),
              _PayRow('NAPSA (5%)', -r.napsa, fmt, AppColors.warning),
              _PayRow('NHIMA (1%)', -r.nhima, fmt, AppColors.warning),
              _PayRow('PAYE', -r.paye, fmt, AppColors.error),
              _PayRow('Total Deductions', -r.deductions, fmt, AppColors.error, bold: true),
              const Divider(color: AppColors.divider),
              _PayRow('NET PAY', r.netPay, fmt, AppColors.success, bold: true, large: true),
              const SizedBox(height: 16),
              Row(children: [
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 15), label: const Text('Download Payslip', style: TextStyle(fontSize: 12))),
                const SizedBox(width: 10),
                if (r.status != 'Paid')
                  ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.payment, size: 15), label: const Text('Mark as Paid', style: TextStyle(fontSize: 12))),
              ]),
            ]),
          ),
        ],
      ]),
      ),
    );
  }
}

Widget _PayRow(String label, double amount, NumberFormat fmt, Color color, {bool bold = false, bool large = false}) =>
  Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontSize: large ? 14 : 13, fontWeight: bold ? FontWeight.w600 : FontWeight.w400))),
      Text('${amount < 0 ? "- " : ""}ZMW ${fmt.format(amount.abs())}',
        style: TextStyle(color: color, fontSize: large ? 15 : 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
    ]),
  );

class _TaxBandsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(color: AppColors.bgMid, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
        child: Row(children: const [
          Expanded(child: Text('Monthly Income Band (ZMW)', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
          Text('PAYE Rate', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
      _TaxRow('Up to ZMW 4,800', '0% (exempt)', isFirst: true),
      _TaxRow('ZMW 4,801 – 9,200', '25%'),
      _TaxRow('ZMW 9,201 – 12,000', '30%'),
      _TaxRow('Above ZMW 12,000', '37.5%', isLast: true),
    ]),
  );
}

class _TaxRow extends StatelessWidget {
  final String band, rate;
  final bool isFirst, isLast;
  const _TaxRow(this.band, this.rate, {this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      border: Border(bottom: isLast ? BorderSide.none : const BorderSide(color: AppColors.divider)),
    ),
    child: Row(children: [
      Expanded(child: Text(band, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Text(rate, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}
