import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';

class GuardAttendanceScreen extends StatelessWidget {
  const GuardAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guard = MockDataService.guards.first;
    final records = MockDataExt.attendance
        .where((r) => r.guardId == guard.id)
        .toList()
      ..sort((a, b) => b.clockIn.compareTo(a.clockIn));

    final dateFmt = DateFormat('EEE, d MMM');
    final timeFmt = DateFormat('HH:mm');

    final totalDays = records.length;
    final presentDays = records.where((r) => r.status == 'Present').length;
    final lateDays = records.where((r) => r.status == 'Late').length;
    final absentDays = records.where((r) => r.status == 'Absent').length;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgMid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Attendance', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats row
          Row(children: [
            _StatTile(label: 'Total', value: '$totalDays', color: AppColors.primary),
            const SizedBox(width: 10),
            _StatTile(label: 'Present', value: '$presentDays', color: AppColors.success),
            const SizedBox(width: 10),
            _StatTile(label: 'Late', value: '$lateDays', color: AppColors.warning),
            const SizedBox(width: 10),
            _StatTile(label: 'Absent', value: '$absentDays', color: AppColors.error),
          ]),
          const SizedBox(height: 8),
          // Attendance rate bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Attendance Rate', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(
                  totalDays == 0 ? '—' : '${((presentDays + lateDays) * 100 ~/ totalDays)}%',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalDays == 0 ? 0 : (presentDays + lateDays) / totalDays,
                  backgroundColor: AppColors.divider,
                  color: AppColors.success,
                  minHeight: 8,
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          const Text('History', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          if (records.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No attendance records found.', style: TextStyle(color: AppColors.textMuted)),
            )),

          ...records.map((r) {
            Color statusColor;
            IconData statusIcon;
            switch (r.status) {
              case 'Present':
                statusColor = AppColors.success; statusIcon = Icons.check_circle_outline; break;
              case 'Late':
                statusColor = AppColors.warning; statusIcon = Icons.schedule; break;
              case 'Absent':
                statusColor = AppColors.error; statusIcon = Icons.cancel_outlined; break;
              case 'On Leave':
                statusColor = AppColors.info; statusIcon = Icons.beach_access_outlined; break;
              default:
                statusColor = AppColors.textMuted; statusIcon = Icons.help_outline;
            }

            String? hoursText;
            if (r.clockIn != null && r.clockOut != null) {
              final diff = r.clockOut!.difference(r.clockIn!);
              hoursText = '${diff.inHours}h ${diff.inMinutes % 60}m';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder, width: 0.5),
              ),
              child: Row(children: [
                Icon(statusIcon, color: statusColor, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(dateFmt.format(r.clockIn ?? DateTime.now()), style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(children: [
                    if (r.clockIn != null) ...[
                      const Icon(Icons.login, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(timeFmt.format(r.clockIn!), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                    if (r.clockOut != null) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.logout, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(timeFmt.format(r.clockOut!), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                    if (hoursText != null) ...[
                      const SizedBox(width: 10),
                      Text('· $hoursText', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                    if (r.clockIn == null && r.status != 'On Leave')
                      const Text('No clock-in recorded', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    if (r.status == 'On Leave')
                      const Text('Leave day', style: TextStyle(color: AppColors.info, fontSize: 11)),
                  ]),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(r.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
            );
          }),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  ));
}
