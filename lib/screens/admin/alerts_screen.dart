import 'package:flutter/material.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminAlertsScreen extends StatefulWidget {
  const AdminAlertsScreen({super.key});
  @override
  State<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends State<AdminAlertsScreen> {
  // Alert trigger toggles
  bool _incidentHigh   = true;
  bool _incidentAll    = false;
  bool _patrolMissed   = true;
  bool _guardLate      = true;
  bool _invoiceDue     = true;

  // Channel toggles
  bool _whatsapp       = true;
  bool _sms            = true;
  bool _email          = false;
  bool _inApp          = true;

  final _templateCtrl  = TextEditingController(text: 'MAGNUM SECURITY ALERT\n\nIncident: {incident_title}\nSite: {site_name}\nSeverity: {severity}\nTime: {time}\n\nGuard: {guard_name}\nContact: {guard_phone}\n\nFor emergencies call: 0800 123 456');

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final incidents = MockDataService.incidents;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(children: [
        if (isDesktop) const AdminSidebar(),
        Expanded(child: Column(children: [
          const AdminTopBar(title: 'Alerts & Notifications'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Alerts & Notifications', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
              const Text('WhatsApp, SMS & email alert configuration for clients and staff', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              const SizedBox(height: 28),

              LayoutBuilder(builder: (ctx, c) {
                final dual = c.maxWidth > 700;
                return dual
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Column(children: [_TriggerCard(this), const SizedBox(height: 16), _ChannelCard(this)])),
                        const SizedBox(width: 20),
                        Expanded(child: Column(children: [_TemplateCard(_templateCtrl), const SizedBox(height: 16), _AlertHistoryCard(incidents)])),
                      ])
                    : Column(children: [_TriggerCard(this), const SizedBox(height: 16), _ChannelCard(this), const SizedBox(height: 16), _TemplateCard(_templateCtrl), const SizedBox(height: 16), _AlertHistoryCard(incidents)]);
              }),
            ]),
          )),
        ])),
      ]),
    );
  }
}

class _TriggerCard extends StatelessWidget {
  final _AdminAlertsScreenState s;
  const _TriggerCard(this.s);

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Alert Triggers',
    subtitle: 'When to send automatic notifications',
    child: Column(children: [
      _Toggle('High / Critical incident reported', s._incidentHigh, (v) => s.setState(() => s._incidentHigh = v), color: AppColors.error),
      _Toggle('Any incident reported', s._incidentAll, (v) => s.setState(() => s._incidentAll = v)),
      _Toggle('Missed patrol checkpoint', s._patrolMissed, (v) => s.setState(() => s._patrolMissed = v), color: AppColors.warning),
      _Toggle('Guard late / absent (clock-in overdue)', s._guardLate, (v) => s.setState(() => s._guardLate = v), color: AppColors.warning),
      _Toggle('Invoice payment due (3 days before)', s._invoiceDue, (v) => s.setState(() => s._invoiceDue = v)),
    ]),
  );
}

class _ChannelCard extends StatelessWidget {
  final _AdminAlertsScreenState s;
  const _ChannelCard(this.s);

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Delivery Channels',
    subtitle: 'How to deliver alerts to clients',
    child: Column(children: [
      _ChannelRow(icon: Icons.chat, label: 'WhatsApp Business', sublabel: 'Via +260 977 123 456', color: const Color(0xFF25D366), enabled: s._whatsapp, onChanged: (v) => s.setState(() => s._whatsapp = v)),
      _ChannelRow(icon: Icons.sms, label: 'SMS (MTN / Airtel)', sublabel: 'Standard SMS to client phone', color: AppColors.info, enabled: s._sms, onChanged: (v) => s.setState(() => s._sms = v)),
      _ChannelRow(icon: Icons.email, label: 'Email', sublabel: 'Via info@magnumsecurity.co.zm', color: AppColors.warning, enabled: s._email, onChanged: (v) => s.setState(() => s._email = v)),
      _ChannelRow(icon: Icons.notifications, label: 'In-App Notification', sublabel: 'Client portal push', color: AppColors.primary, enabled: s._inApp, onChanged: (v) => s.setState(() => s._inApp = v)),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _sendTestAlert(context),
          icon: const Icon(Icons.send, size: 15),
          label: const Text('Send Test Alert'),
        ),
      ),
    ]),
  );

  void _sendTestAlert(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Test alert sent via active channels'),
      backgroundColor: AppColors.success,
      duration: Duration(seconds: 3),
    ));
  }
}

class _TemplateCard extends StatelessWidget {
  final TextEditingController ctrl;
  const _TemplateCard(this.ctrl);

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'WhatsApp / SMS Template',
    subtitle: 'Message body for automated incident alerts',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.bgMid, borderRadius: BorderRadius.circular(8)),
        child: Wrap(spacing: 6, runSpacing: 6, children: const [
          _TagChip('{incident_title}'), _TagChip('{site_name}'),
          _TagChip('{severity}'), _TagChip('{time}'),
          _TagChip('{guard_name}'), _TagChip('{guard_phone}'),
        ]),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: ctrl,
        maxLines: 10,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: AppColors.textSecondary, height: 1.6),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(12),
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        ElevatedButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Template saved'), backgroundColor: AppColors.success)),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          child: const Text('Save Template', style: TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
          child: const Text('Reset to Default', style: TextStyle(fontSize: 12)),
        ),
      ]),
    ]),
  );
}

class _AlertHistoryCard extends StatelessWidget {
  final List incidents;
  const _AlertHistoryCard(this.incidents);

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Recent Alert History',
    subtitle: 'Last 5 notifications sent',
    child: Column(children: incidents.take(5).map((inc) {
      final sent = inc.severity == 'High' || inc.severity == 'Critical';
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: (sent ? const Color(0xFF25D366) : AppColors.textMuted).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(sent ? Icons.chat : Icons.notifications_off, color: sent ? const Color(0xFF25D366) : AppColors.textMuted, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(inc.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${sent ? "WhatsApp + SMS" : "Below threshold — not sent"}  •  ${inc.site}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (sent ? AppColors.success : AppColors.textMuted).withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(sent ? 'Sent' : 'Skipped', style: TextStyle(color: sent ? AppColors.success : AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
      );
    }).toList()),
  );
}

class _Panel extends StatelessWidget {
  final String title, subtitle;
  final Widget child;
  const _Panel({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      const Divider(color: AppColors.divider),
      const SizedBox(height: 8),
      child,
    ]),
  );
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;
  const _Toggle(this.label, this.value, this.onChanged, {this.color});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      activeColor: color ?? AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    ),
  );
}

class _ChannelRow extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;
  final Color color;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _ChannelRow({required this.icon, required this.label, required this.sublabel, required this.color, required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
        Text(sublabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ])),
      Switch(value: enabled, onChanged: onChanged, activeColor: color),
    ]),
  );
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip(this.tag);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {},
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Text(tag, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'monospace')),
    ),
  );
}
