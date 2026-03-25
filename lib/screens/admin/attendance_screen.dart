import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});
  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Present', 'Late', 'Absent', 'On Leave'];

  Color _statusColor(String s) {
    switch (s) {
      case 'Present':  return AppColors.success;
      case 'Late':     return AppColors.warning;
      case 'Absent':   return AppColors.error;
      case 'On Leave': return AppColors.info;
      default:         return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final records = MockDataExt.attendance
        .where((r) => _filter == 'All' || r.status == _filter)
        .toList();

    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('dd MMM');

    // Summary counts
    final counts = {for (var s in _filters.skip(1)) s: MockDataExt.attendance.where((r) => r.status == s).length};
    final total  = MockDataExt.attendance.length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(children: [
        if (isDesktop) const AdminSidebar(),
        Expanded(child: Column(children: [
          const AdminTopBar(title: 'Attendance Tracker'),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Attendance Tracker', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('Guard clock-in/out records — today & recent', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ]),
                ElevatedButton.icon(
                  onPressed: () => _showClockInDialog(context),
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Log Clock-In'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                ),
              ]),
              const SizedBox(height: 24),

              // Summary strip
              LayoutBuilder(builder: (ctx, c) {
                final cols = c.maxWidth > 700 ? 5 : c.maxWidth > 450 ? 3 : 2;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  SizedBox(width: (c.maxWidth - (cols-1)*12) / cols, child: _AttSummaryCard(label: 'Total on roster', value: '$total', color: AppColors.primary)),
                  ..._filters.skip(1).map((s) => SizedBox(
                    width: (c.maxWidth - (cols-1)*12) / cols,
                    child: _AttSummaryCard(label: s, value: '${counts[s] ?? 0}', color: _statusColor(s)),
                  )),
                ]);
              }),
              const SizedBox(height: 24),

              // Filter chips
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
                children: _filters.map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    side: BorderSide(color: _filter == f ? AppColors.primary : AppColors.cardBorder),
                    labelStyle: TextStyle(color: _filter == f ? AppColors.primary : AppColors.textMuted, fontSize: 12),
                  ),
                )).toList(),
              )),
              const SizedBox(height: 16),

              // Table header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: AppColors.bgMid, borderRadius: BorderRadius.circular(8)),
                child: Row(children: const [
                  Expanded(flex: 3, child: Text('Guard', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(flex: 2, child: Text('Site', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Shift', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Clock In', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Clock Out', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Hours', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                  Expanded(child: Text('Status', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                ]),
              ),
              const SizedBox(height: 8),

              ...records.map((r) {
                final hw = r.hoursWorked;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder, width: 0.5),
                  ),
                  child: Row(children: [
                    Expanded(flex: 3, child: Row(children: [
                      CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(r.guardName[0], style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r.guardName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(r.guardBadge, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ])),
                    ])),
                    Expanded(flex: 2, child: Text(r.site, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: (r.shift == 'Day' ? AppColors.primary : AppColors.info).withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(r.shift, style: TextStyle(color: r.shift == 'Day' ? AppColors.primary : AppColors.info, fontSize: 10, fontWeight: FontWeight.w600)),
                    )),
                    Expanded(child: Text(timeFmt.format(r.clockIn), style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                    Expanded(child: Text(r.clockOut != null ? timeFmt.format(r.clockOut!) : '—', style: TextStyle(color: r.clockOut != null ? AppColors.textPrimary : AppColors.textMuted, fontSize: 12))),
                    Expanded(child: Text(hw != null ? '${hw.inHours}h ${hw.inMinutes % 60}m' : '—', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                    Expanded(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: _statusColor(r.status).withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                      child: Text(r.status, style: TextStyle(color: _statusColor(r.status), fontSize: 10, fontWeight: FontWeight.w700)),
                    )),
                  ]),
                );
              }),

              if (records.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No records match the filter.', style: TextStyle(color: AppColors.textMuted)))),
            ]),
          )),
        ])),
      ]),
      ),
    );
  }

  void _showClockInDialog(BuildContext context) {
    final guards = MockDataService.guards;
    String? selectedGuard;
    String selectedShift = 'Day';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setState) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Guard Clock-In', style: TextStyle(color: AppColors.textPrimary)),
        content: SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: selectedGuard,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: 'Select Guard', prefixIcon: Icon(Icons.person)),
              items: guards.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} — ${g.badgeNumber}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)))).toList(),
              onChanged: (v) => setState(() => selectedGuard = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedShift,
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(labelText: 'Shift', prefixIcon: Icon(Icons.schedule)),
              items: const [
                DropdownMenuItem(value: 'Day',   child: Text('Day (06:00–18:00)',   style: TextStyle(color: AppColors.textPrimary))),
                DropdownMenuItem(value: 'Night', child: Text('Night (18:00–06:00)', style: TextStyle(color: AppColors.textPrimary))),
              ],
              onChanged: (v) => setState(() => selectedShift = v!),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.schedule, color: AppColors.primary, size: 14),
                const SizedBox(width: 8),
                Text('Clock-in time: ${DateFormat("HH:mm").format(DateTime.now())}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clock-in recorded successfully'), backgroundColor: AppColors.success));
            },
            child: const Text('Confirm Clock-In'),
          ),
        ],
      )),
    );
  }
}

class _AttSummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _AttSummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]),
  );
}
