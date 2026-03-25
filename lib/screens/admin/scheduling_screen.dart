import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/admin_navigation.dart';

class AdminSchedulingScreen extends StatefulWidget {
  const AdminSchedulingScreen({super.key});
  @override
  State<AdminSchedulingScreen> createState() => _AdminSchedulingScreenState();
}

class _AdminSchedulingScreenState extends State<AdminSchedulingScreen> {
  late DateTime _weekStart;
  final _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  String get _weekLabel {
    final fmt = DateFormat('d MMM yyyy');
    return '${fmt.format(_weekStart)} – ${fmt.format(_weekStart.add(const Duration(days: 6)))}';
  }

  // Mock shift data  [guard_index, day_index] => shift
  static const _shifts = <String, String>{
    'G001-0': 'Day', 'G001-1': 'Day', 'G001-2': 'Day', 'G001-3': 'Day', 'G001-4': 'Day',
    'G002-0': 'Night', 'G002-1': 'Night', 'G002-2': 'Night', 'G002-3': 'Night', 'G002-4': 'Night', 'G002-5': 'Night',
    'G003-1': 'Day', 'G003-2': 'Day', 'G003-3': 'Day', 'G003-4': 'Day', 'G003-5': 'Day',
    'G005-0': 'Day', 'G005-1': 'Night', 'G005-2': 'Day', 'G005-3': 'Night', 'G005-4': 'Day',
    'G006-0': 'Day', 'G006-1': 'Day', 'G006-2': 'Day', 'G006-3': 'Day', 'G006-4': 'Day', 'G006-5': 'Day', 'G006-6': 'Night',
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final guards = MockDataService.guards.where((g) => g.status == 'Active').toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const AdminDrawer() : null,
      body: Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                const AdminTopBar(title: 'Shift Scheduling'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Shift Scheduling', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                              Text('Weekly roster — $_weekLabel', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                            ]),
                            Row(children: [
                              OutlinedButton.icon(onPressed: _prevWeek, icon: const Icon(Icons.chevron_left, size: 16), label: const Text('Prev'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(onPressed: _nextWeek, icon: const Icon(Icons.chevron_right, size: 16), label: const Text('Next'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10))),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Shift legend
                        Wrap(spacing: 16, children: [
                          _ShiftLegend(label: 'Day Shift (06:00–18:00)', color: AppColors.primary),
                          _ShiftLegend(label: 'Night Shift (18:00–06:00)', color: AppColors.info),
                          _ShiftLegend(label: 'Day Off / Leave', color: AppColors.surface),
                        ]),
                        const SizedBox(height: 20),

                        // Schedule grid
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder, width: 0.5),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - (isDesktop ? 278 : 48)),
                              child: Column(
                                children: [
                                  // Header row
                                  Container(
                                    color: AppColors.bgMid,
                                    child: Row(children: [
                                      const SizedBox(width: 180, child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text('Guard', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                      )),
                                      ..._days.map((d) => SizedBox(
                                        width: 90,
                                        child: Center(child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Text(d, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                        )),
                                      )),
                                    ]),
                                  ),
                                  const Divider(color: AppColors.divider, height: 1),
                                  // Guard rows
                                  ...guards.asMap().entries.map((e) {
                                    final g = e.value;
                                    return Column(children: [
                                      if (e.key > 0) const Divider(color: AppColors.divider, height: 1),
                                      Row(children: [
                                        SizedBox(
                                          width: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(children: [
                                              CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(g.name[0], style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700))),
                                              const SizedBox(width: 8),
                                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Text(g.name.split(' ')[0], style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                                                Text(g.role, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                              ])),
                                            ]),
                                          ),
                                        ),
                                        ...[0, 1, 2, 3, 4, 5, 6].map((dayIdx) {
                                          final shift = _shifts['${g.id}-$dayIdx'];
                                          return SizedBox(
                                            width: 90,
                                            height: 52,
                                            child: Center(
                                              child: shift != null
                                                  ? Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                      decoration: BoxDecoration(
                                                        color: (shift == 'Day' ? AppColors.primary : AppColors.info).withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: (shift == 'Day' ? AppColors.primary : AppColors.info).withOpacity(0.3)),
                                                      ),
                                                      child: Text(shift, style: TextStyle(color: shift == 'Day' ? AppColors.primary : AppColors.info, fontSize: 11, fontWeight: FontWeight.w600)),
                                                    )
                                                  : const Icon(Icons.remove, color: AppColors.divider, size: 16),
                                            ),
                                          );
                                        }),
                                      ]),
                                    ]);
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        // Coverage stats
                        const Text('Daily Coverage Summary', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 700 ? 7 : c.maxWidth > 400 ? 4 : 2;
                          return Wrap(
                            spacing: 10, runSpacing: 10,
                            children: _days.asMap().entries.map((e) {
                              final dayIdx = e.key;
                              final dayLabel = e.value;
                              final count = _shifts.keys.where((k) => k.endsWith('-$dayIdx')).length;
                              return SizedBox(
                                width: (c.maxWidth - (cols - 1) * 10) / cols,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.cardBorder, width: 0.5),
                                  ),
                                  child: Column(children: [
                                    Text(dayLabel, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text('$count', style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w800)),
                                    const Text('on shift', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                  ]),
                                ),
                              );
                            }).toList(),
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
      ),
    );
  }
}

class _ShiftLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _ShiftLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 14, height: 14, decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(3), border: Border.all(color: color.withOpacity(0.6)))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
  ]);
}
