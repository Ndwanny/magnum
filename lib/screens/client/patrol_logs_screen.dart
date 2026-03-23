import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import 'client_dashboard_screen.dart';

class PatrolLogsScreen extends StatelessWidget {
  const PatrolLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final logs = MockDataService.patrolLogs;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) const ClientSidebar(),
          Expanded(
            child: Column(
              children: [
                ClientTopBar(user: null),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Patrol Logs', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        const Text('Guard patrol records and checkpoint scans.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 28),
                        ...logs.map((log) {
                          final timeFmt = DateFormat('HH:mm');
                          final dateFmt = DateFormat('dd MMM yyyy');
                          final statusColor = log.status == 'Completed' ? AppColors.success : log.status == 'Ongoing' ? AppColors.info : AppColors.error;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder, width: 0.5),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(log.guardName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                                  Text('Badge: ${log.guardBadge}  •  ${log.site}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ])),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                                  child: Text(log.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(Icons.schedule, color: AppColors.textMuted, size: 13),
                                const SizedBox(width: 4),
                                Text('${dateFmt.format(log.startTime)}  ${timeFmt.format(log.startTime)}${log.endTime != null ? " — ${timeFmt.format(log.endTime!)}" : " (ongoing)"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                              ]),
                              const SizedBox(height: 16),
                              const Text('Checkpoints', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              ...log.checkpoints.map((cp) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(children: [
                                  Icon(cp.isOk ? Icons.check_circle : Icons.cancel, color: cp.isOk ? AppColors.success : AppColors.error, size: 15),
                                  const SizedBox(width: 8),
                                  Text(cp.checkpointName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const Spacer(),
                                  Text(timeFmt.format(cp.scannedAt), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ]),
                              )),
                              if (log.notes.isNotEmpty) ...[
                                const Divider(color: AppColors.divider),
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Icon(Icons.notes, color: AppColors.textMuted, size: 13),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(log.notes, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic))),
                                ]),
                              ],
                            ]),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
