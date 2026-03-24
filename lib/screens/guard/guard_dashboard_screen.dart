import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/guard_shift_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';

class GuardDashboardScreen extends StatelessWidget {
  const GuardDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<AuthService>();
    final shift = context.watch<GuardShiftService>();
    // Use first guard as demo profile
    final guard = MockDataService.guards.first;
    final patrols = MockDataService.patrolLogs.where((p) => p.guardBadge == guard.badgeNumber).toList();
    final incidents = MockDataService.incidents.where((i) => i.reportedBy == guard.name).toList();
    final timeFmt = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: const GuardDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.bgMid,
        title: Row(children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.shield, color: Colors.black, size: 16)),
          const SizedBox(width: 8),
          const Text('Magnum Security', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          Builder(builder: (ctx) => TextButton(
            onPressed: () {
              ctx.read<AuthService>().logout();
              Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          )),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Guard profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.bgMid]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(guard.name[0], style: const TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(guard.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('Badge: ${guard.badgeNumber}  •  ${guard.role}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.circle, color: AppColors.success, size: 8),
                    SizedBox(width: 5),
                    Text('On Duty', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ])),
            ]),
          ),
          const SizedBox(height: 20),

          // Today's shift
          _GuardSection(title: "Today's Shift"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _ShiftInfoCol(label: 'Site', value: guard.currentSite),
                _ShiftInfoCol(label: 'Shift', value: 'Day — 06:00–18:00'),
                _ShiftInfoCol(
                  label: 'Clocked In',
                  value: shift.isClockedIn ? timeFmt.format(shift.clockInTime!) : '—',
                ),
                _ShiftInfoCol(
                  label: 'Hours',
                  value: shift.isClockedIn ? '${shift.hoursWorked.inHours}h ${shift.hoursWorked.inMinutes % 60}m' : 'Not clocked in',
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: shift.isClockedIn
                  ? ElevatedButton.icon(
                      onPressed: () => _confirmClockOut(context, shift),
                      icon: const Icon(Icons.logout, size: 16),
                      label: const Text('Clock Out'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: Colors.black),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _confirmClockIn(context, shift, guard.currentSite),
                      icon: const Icon(Icons.login, size: 16),
                      label: const Text('Clock In'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.black),
                    ),
                ),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _showReportDialog(context),
                  icon: const Icon(Icons.report_outlined, size: 16),
                  label: const Text('Report Incident'),
                )),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Quick actions
          _GuardSection(title: 'Quick Actions'),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2,
            children: [
              _QuickAction(icon: Icons.qr_code_scanner, label: 'Scan Checkpoint', color: AppColors.primary, onTap: () => _showQrScan(context)),
              _QuickAction(icon: Icons.warning_amber, label: 'Log Incident', color: AppColors.warning, onTap: () => _showReportDialog(context)),
              _QuickAction(icon: Icons.calendar_month, label: 'My Schedule', color: AppColors.info, onTap: () => Navigator.pushNamed(context, AppRoutes.guardSchedule)),
              _QuickAction(icon: Icons.emergency, label: 'Emergency Panic', color: AppColors.error, onTap: () => _triggerPanic(context)),
            ],
          ),
          const SizedBox(height: 20),

          // Today's patrols
          _GuardSection(title: 'My Patrols Today'),
          ...patrols.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: (p.status == 'Completed' ? AppColors.success : AppColors.info).withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: Text(p.status, style: TextStyle(color: p.status == 'Completed' ? AppColors.success : AppColors.info, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text('${p.checkpoints.length} checkpoints', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                Text(timeFmt.format(p.startTime), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: p.checkpoints.where((c) => c.isOk).length / p.checkpoints.length.clamp(1, 99),
                backgroundColor: AppColors.divider,
                color: AppColors.success,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 4),
              Text('${p.checkpoints.where((c) => c.isOk).length} / ${p.checkpoints.length} checkpoints scanned', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
          )),
          if (patrols.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
              child: const Center(child: Text('No patrols assigned today.', style: TextStyle(color: AppColors.textMuted, fontSize: 13))),
            ),
          const SizedBox(height: 20),

          // Incidents filed
          _GuardSection(title: 'Incidents I Filed'),
          ...incidents.take(3).map((inc) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(inc.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(timeFmt.format(inc.reportedAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(inc.status, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
          )),
          if (incidents.isEmpty)
            const Text('No incidents filed.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),

          const SizedBox(height: 24),
          // Bottom nav links
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.guardSchedule),
              icon: const Icon(Icons.calendar_month, size: 16),
              label: const Text('Full Schedule'),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.guardAttendance),
              icon: const Icon(Icons.history, size: 16),
              label: const Text('Attendance'),
            )),
          ]),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _confirmClockIn(BuildContext context, GuardShiftService shift, String site) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Clock In', style: TextStyle(color: AppColors.textPrimary)),
      content: Text('Clock in at $site for the day shift?', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await shift.clockIn(site);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clocked in successfully'), backgroundColor: AppColors.success));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.black),
          child: const Text('Clock In'),
        ),
      ],
    ));
  }

  void _confirmClockOut(BuildContext context, GuardShiftService shift) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Confirm Clock-Out', style: TextStyle(color: AppColors.textPrimary)),
      content: const Text('Are you sure you want to clock out? Your shift will be recorded.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await shift.clockOut();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clocked out successfully'), backgroundColor: AppColors.success));
          },
          child: const Text('Clock Out'),
        ),
      ],
    ));
  }

  void _showReportDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Report Incident', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe the incident...', alignLabelWithHint: true)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident report submitted'), backgroundColor: AppColors.success)); }, child: const Text('Submit')),
      ],
    ));
  }

  void _showQrScan(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Scan Checkpoint', style: TextStyle(color: AppColors.textPrimary)),
      content: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(color: AppColors.bgMid, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.4))),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 64),
          SizedBox(height: 12),
          Text('Point camera at QR code', style: TextStyle(color: AppColors.textMuted, fontSize: 12), textAlign: TextAlign.center),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checkpoint scanned: Gate 3 — ✓ OK'), backgroundColor: AppColors.success)); }, child: const Text('Simulate Scan')),
      ],
    ));
  }

  void _triggerPanic(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(children: const [Icon(Icons.emergency, color: AppColors.error), SizedBox(width: 8), Text('EMERGENCY PANIC', style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w700))]),
      content: const Text('This will immediately alert the operations centre and dispatch armed response to your GPS location. Only use in genuine emergencies.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PANIC ALERT SENT — Response dispatched', style: TextStyle(fontWeight: FontWeight.w700)), backgroundColor: AppColors.error, duration: Duration(seconds: 5))); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
          child: const Text('SEND PANIC ALERT'),
        ),
      ],
    ));
  }
}

class _GuardSection extends StatelessWidget {
  final String title;
  const _GuardSection({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
  );
}

class _ShiftInfoCol extends StatelessWidget {
  final String label, value;
  const _ShiftInfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    const SizedBox(height: 2),
    Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
  ]);
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    ),
  );
}

class GuardDrawer extends StatelessWidget {
  const GuardDrawer();

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.bgMid,
    child: Column(children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: AppColors.bgDark),
        child: Row(children: [
          Icon(Icons.shield, color: AppColors.primary, size: 32),
          SizedBox(width: 12),
          Text('Guard Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
      ListTile(
        leading: const Icon(Icons.dashboard_outlined, color: AppColors.textMuted, size: 18),
        title: const Text('Dashboard', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        onTap: () { Navigator.pop(context); Navigator.pushNamedAndRemoveUntil(context, AppRoutes.guardDashboard, (r) => false); },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_month_outlined, color: AppColors.textMuted, size: 18),
        title: const Text('My Schedule', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        onTap: () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.guardSchedule); },
      ),
      ListTile(
        leading: const Icon(Icons.history, color: AppColors.textMuted, size: 18),
        title: const Text('Attendance', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        onTap: () { Navigator.pop(context); Navigator.pushNamed(context, AppRoutes.guardAttendance); },
      ),
      const Spacer(),
      const Divider(color: AppColors.divider),
      Builder(builder: (ctx) => ListTile(
        leading: const Icon(Icons.logout, color: AppColors.textMuted, size: 18),
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        onTap: () {
          ctx.read<AuthService>().logout();
          Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
        },
      )),
      const SizedBox(height: 8),
    ]),
  );
}
