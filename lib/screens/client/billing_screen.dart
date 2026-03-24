import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/payment_service.dart';
import '../../services/mock_data_service.dart';
import '../../models/invoice.dart';
import '../../utils/constants.dart';
import 'client_dashboard_screen.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final invoices = MockDataService.invoices;
    final fmt = NumberFormat('#,##0.00', 'en_US');

    double totalPaid    = invoices.where((i) => i.status == 'Paid').fold(0, (a, b) => a + b.amount);
    double totalPending = invoices.where((i) => i.status == 'Pending').fold(0, (a, b) => a + b.amount);
    double totalOverdue = invoices.where((i) => i.status == 'Overdue').fold(0, (a, b) => a + b.amount);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const ClientDrawer() : null,
      body: Builder(
        builder: (scaffoldCtx) => Row(
        children: [
          if (isDesktop) const ClientSidebar(),
          Expanded(
            child: Column(
              children: [
                ClientTopBar(user: null, onMenuTap: isDesktop ? null : () => Scaffold.of(scaffoldCtx).openDrawer()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Billing & Invoices', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        const Text('All in Zambian Kwacha (ZMW)', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Summary cards
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 600 ? 3 : 1;
                          return Wrap(
                            spacing: 16, runSpacing: 16,
                            children: [
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SummaryCard(label: 'Total Paid', amount: 'ZMW ${fmt.format(totalPaid)}', color: AppColors.success, icon: Icons.check_circle)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SummaryCard(label: 'Pending Payment', amount: 'ZMW ${fmt.format(totalPending)}', color: AppColors.warning, icon: Icons.pending)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: _SummaryCard(label: 'Overdue', amount: 'ZMW ${fmt.format(totalOverdue)}', color: AppColors.error, icon: Icons.error_outline)),
                            ],
                          );
                        }),

                        const SizedBox(height: 32),
                        const Text('Invoice History', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ...invoices.map((inv) => _InvoiceCard(invoice: inv, fmt: fmt)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, amount;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.label, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text(amount, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}

class _InvoiceCard extends StatefulWidget {
  final Invoice invoice;
  final NumberFormat fmt;
  const _InvoiceCard({required this.invoice, required this.fmt});
  @override
  State<_InvoiceCard> createState() => _InvoiceCardState();
}


class _InvoiceCardState extends State<_InvoiceCard> {
  bool _expanded = false;

  void _showPayDialog(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (_) => _LencoPaymentDialog(invoice: inv),
    );
  }

  Color get _statusColor {
    switch (widget.invoice.status) {
      case 'Paid':    return AppColors.success;
      case 'Pending': return AppColors.warning;
      case 'Overdue': return AppColors.error;
      default:        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    final dateFmt = DateFormat('dd MMM yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(inv.invoiceNumber, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Issued: ${dateFmt.format(inv.issuedDate)}  •  Due: ${dateFmt.format(inv.dueDate)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('ZMW ${widget.fmt.format(inv.amount)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                    child: Text(inv.status, style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...inv.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(child: Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                      Text('x${item.quantity}', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                      const SizedBox(width: 24),
                      Text('ZMW ${widget.fmt.format(item.total)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ]),
                  )),
                  const Divider(color: AppColors.divider),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Total: ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      Text('ZMW ${widget.fmt.format(inv.amount)}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ZRA VAT breakdown
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.bgDark, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Subtotal (excl. VAT)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text('ZMW ${widget.fmt.format(inv.amount / 1.16)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('VAT @ 16% (ZRA)', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Text('ZMW ${widget.fmt.format(inv.amount - inv.amount / 1.16)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ]),
                      const Divider(color: AppColors.divider, height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Total (incl. VAT)', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('ZMW ${widget.fmt.format(inv.amount)}', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), textStyle: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    if (inv.status != 'Paid')
                      ElevatedButton.icon(
                        onPressed: () => _showPayDialog(context, inv),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pay Now'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), textStyle: const TextStyle(fontSize: 12)),
                      ),
                  ]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Lenco / Broadpay payment dialog ───────────────────────────
class _LencoPaymentDialog extends StatefulWidget {
  final Invoice invoice;
  const _LencoPaymentDialog({required this.invoice});
  @override
  State<_LencoPaymentDialog> createState() => _LencoPaymentDialogState();
}

class _LencoPaymentDialogState extends State<_LencoPaymentDialog> {
  String _method = 'mtn_momo';
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  PaymentResponse? _result;

  static const _mtnColor    = Color(0xFFFFCC00);
  static const _airtelColor = Color(0xFFE40000);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final inv = widget.invoice;

    if (_result != null && _result!.success) return _successView(inv);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Pay with Lenco', style: TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.primary.withOpacity(0.25))),
            child: Column(children: [
              Text('ZMW ${fmt.format(inv.amount)}', style: const TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w800)),
              Text(inv.invoiceNumber, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 20),
          const Align(alignment: Alignment.centerLeft, child: Text('Select payment method:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
          const SizedBox(height: 10),
          // MTN
          _MethodTile(
            icon: Icons.phone_android, label: 'MTN Mobile Money', sub: 'ZMW wallet · instant push',
            color: _mtnColor, selected: _method == 'mtn_momo',
            onTap: () => setState(() => _method = 'mtn_momo'),
          ),
          const SizedBox(height: 8),
          // Airtel
          _MethodTile(
            icon: Icons.phone_android, label: 'Airtel Money', sub: 'ZMW wallet · instant push',
            color: _airtelColor, selected: _method == 'airtel_money',
            onTap: () => setState(() => _method = 'airtel_money'),
          ),
          const SizedBox(height: 8),
          // Card
          _MethodTile(
            icon: Icons.credit_card, label: 'Visa / Mastercard', sub: 'Secure hosted card checkout',
            color: AppColors.info, selected: _method == 'card',
            onTap: () => setState(() => _method = 'card'),
          ),
          // Mobile number field
          if (_method == 'mtn_momo' || _method == 'airtel_money') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '260 97X XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                helperText: _method == 'mtn_momo'
                    ? 'You will receive an MTN payment prompt'
                    : 'You will receive an Airtel Money prompt',
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.error.withOpacity(0.3))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12))),
              ]),
            ),
          ],
          // Lenco branding
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.lock, size: 12, color: AppColors.textMuted),
            SizedBox(width: 4),
            Text('Secured by Lenco / Broadpay', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ]),
        ])),
      ),
      actions: [
        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading ? null : _pay,
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Text(_method == 'card' ? 'Go to Checkout' : 'Pay Now'),
        ),
      ],
    );
  }

  Widget _successView(Invoice inv) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 56),
          const SizedBox(height: 16),
          Text(_method == 'card' ? 'Redirecting to checkout...' : 'Payment Initiated!',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            _method == 'card'
                ? 'Complete payment in the secure checkout page.'
                : 'Check your phone for the payment prompt.\nAmount: ZMW ${fmt.format(inv.amount)}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (_result?.ussdCode != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgDark, borderRadius: BorderRadius.circular(8)),
              child: Text('USSD: ${_result!.ussdCode}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1)),
            ),
          ],
        ]),
      ),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
      ],
    );
  }

  Future<void> _pay() async {
    if ((_method == 'mtn_momo' || _method == 'airtel_money') && _phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your mobile number');
      return;
    }
    setState(() { _loading = true; _error = null; });

    PaymentResponse result;
    if (_method == 'card') {
      result = await LencoPaymentService.initiateCardPayment(
        invoiceNumber: widget.invoice.invoiceNumber,
        amountZmw: widget.invoice.amount,
        customerName: widget.invoice.clientName,
        customerEmail: '',
      );
    } else {
      result = await LencoPaymentService.initiateMobileMoney(
        invoiceNumber: widget.invoice.invoiceNumber,
        amountZmw: widget.invoice.amount,
        method: _method,
        phoneNumber: _phoneCtrl.text.trim(),
        customerName: widget.invoice.clientName,
        customerEmail: '',
      );
    }

    if (!mounted) return;
    if (result.success) {
      // Record the pending transaction in the DB
      await DatabaseService.createPaymentTransaction(
        invoiceId: widget.invoice.id,
        amount: widget.invoice.amount,
        method: _method,
        phoneNumber: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      );
      // If card, open the checkout URL
      if (_method == 'card' && result.checkoutUrl != null) {
        final uri = Uri.parse(result.checkoutUrl!);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      setState(() { _result = result; _loading = false; });
    } else {
      setState(() { _error = result.message; _loading = false; });
    }
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile({required this.icon, required this.label, required this.sub, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.1) : AppColors.bgDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? color : AppColors.cardBorder, width: selected ? 1.5 : 0.5),
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
          Text(sub, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        ])),
        if (selected) Icon(Icons.check_circle, color: color, size: 18),
      ]),
    ),
  );
}

