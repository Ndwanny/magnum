import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../models/incident.dart';
import '../../utils/constants.dart';
import '../../widgets/dashboard/stat_card.dart';
import 'client_dashboard_screen.dart';

class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});
  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Open', 'In Progress', 'Resolved', 'Closed'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final incidents = MockDataService.incidents
        .where((i) => _filter == 'All' || i.status == _filter)
        .toList();

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
                        const Text('Incident Reports', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        const Text('All security incidents reported at your sites.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
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
                          ),
                        ),

                        const SizedBox(height: 20),
                        ...incidents.map((inc) => _IncidentCard(incident: inc)),
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

class _IncidentCard extends StatefulWidget {
  final Incident incident;
  const _IncidentCard({required this.incident});
  @override
  State<_IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<_IncidentCard> {
  bool _expanded = false;

  Color get _severityColor {
    switch (widget.incident.severity) {
      case 'Critical': return AppColors.error;
      case 'High':     return AppColors.warning;
      case 'Medium':   return AppColors.info;
      default:         return AppColors.success;
    }
  }

  Color get _statusColor {
    switch (widget.incident.status) {
      case 'Open':        return AppColors.error;
      case 'In Progress': return AppColors.warning;
      case 'Resolved':    return AppColors.success;
      default:            return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inc = widget.incident;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _expanded ? AppColors.primary.withOpacity(0.4) : AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: _severityColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(inc.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('${inc.site}  •  Reported by ${inc.reportedBy}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ]),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _Badge(label: inc.severity, color: _severityColor),
                  const SizedBox(height: 4),
                  _Badge(label: inc.status, color: _statusColor),
                ]),
                const SizedBox(width: 8),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted, size: 20),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(inc.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.schedule, color: AppColors.textMuted, size: 13),
                const SizedBox(width: 4),
                Text('Reported: ${DateFormat("dd MMM yyyy HH:mm").format(inc.reportedAt)}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                if (inc.resolvedAt != null) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.check_circle_outline, color: AppColors.success, size: 13),
                  const SizedBox(width: 4),
                  Text('Resolved: ${DateFormat("dd MMM yyyy HH:mm").format(inc.resolvedAt!)}', style: const TextStyle(color: AppColors.success, fontSize: 11)),
                ],
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
    child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
  );
}
