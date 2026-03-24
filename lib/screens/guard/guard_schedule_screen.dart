import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import 'guard_dashboard_screen.dart';

class GuardScheduleScreen extends StatefulWidget {
  const GuardScheduleScreen({super.key});

  @override
  State<GuardScheduleScreen> createState() => _GuardScheduleScreenState();
}

class _GuardScheduleScreenState extends State<GuardScheduleScreen> {
  late DateTime _weekStart;

  // Same shift map as admin scheduling — in a real app this would come from an API
  static const _shifts = <String, String>{
    'G001-0': 'Day',   'G001-1': 'Day',   'G001-2': 'Day',   'G001-3': 'Day',   'G001-4': 'Day',
    'G002-0': 'Night', 'G002-1': 'Night', 'G002-2': 'Night', 'G002-3': 'Night', 'G002-4': 'Night', 'G002-5': 'Night',
    'G003-1': 'Day',   'G003-2': 'Day',   'G003-3': 'Day',   'G003-4': 'Day',   'G003-5': 'Day',
    'G005-0': 'Day',   'G005-1': 'Night', 'G005-2': 'Day',   'G005-3': 'Night', 'G005-4': 'Day',
    'G006-0': 'Day',   'G006-1': 'Day',   'G006-2': 'Day',   'G006-3': 'Day',   'G006-4': 'Day',   'G006-5': 'Day',   'G006-6': 'Night',
  };

  @override
  void initState() {
    super.initState();
    // Set to start of the current week (Monday)
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
  }

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
    final guard = MockDataService.guards.first; // demo: first guard
    final dateFmt = DateFormat('d MMM');
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int totalShifts = 0;
    int dayShifts = 0;
    int nightShifts = 0;
    for (int i = 0; i < 7; i++) {
      final shift = _shifts['${guard.id}-$i'];
      if (shift != null) {
        totalShifts++;
        if (shift == 'Day') dayShifts++; else nightShifts++;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: const GuardDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.bgMid,
        title: const Text('My Schedule', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                _weekStart = now.subtract(Duration(days: now.weekday - 1));
                _weekStart = DateTime(_weekStart.year, _weekStart.month, _weekStart.day);
              });
            },
            child: const Text('Today', style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Week navigator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 0.5),
            ),
            child: Row(children: [
              IconButton(
                onPressed: _prevWeek,
                icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              ),
              Expanded(child: Center(child: Text(
                '${dateFmt.format(_weekStart)} – ${dateFmt.format(_weekStart.add(const Duration(days: 6)))}',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              ))),
              IconButton(
                onPressed: _nextWeek,
                icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Weekly summary
          Row(children: [
            _SummaryChip(label: 'Shifts', value: '$totalShifts', color: AppColors.primary),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Day', value: '$dayShifts', color: AppColors.warning),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Night', value: '$nightShifts', color: AppColors.info),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Off', value: '${7 - totalShifts}', color: AppColors.textMuted),
          ]),
          const SizedBox(height: 20),

          // Day-by-day schedule cards
          const Text('This Week', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...List.generate(7, (i) {
            final date = days[i];
            final isToday = date == todayDate;
            final shift = _shifts['${guard.id}-$i'];
            final shiftColor = shift == 'Day' ? AppColors.warning : shift == 'Night' ? AppColors.info : AppColors.textMuted;
            final shiftTime = shift == 'Day' ? '06:00 – 18:00' : shift == 'Night' ? '18:00 – 06:00' : null;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday ? AppColors.primary.withOpacity(0.4) : AppColors.cardBorder,
                  width: isToday ? 1.0 : 0.5,
                ),
              ),
              child: Row(children: [
                // Day label
                SizedBox(
                  width: 56,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(dayLabels[i], style: TextStyle(
                      color: isToday ? AppColors.primary : AppColors.textMuted,
                      fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                    )),
                    Text(dateFmt.format(date), style: TextStyle(
                      color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 13, fontWeight: FontWeight.w600,
                    )),
                  ]),
                ),
                Container(width: 1, height: 36, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 14)),
                // Shift info
                Expanded(child: shift != null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: shiftColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                          child: Text('$shift Shift', style: TextStyle(color: shiftColor, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 8),
                        Text(shiftTime!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Text('Site: ${guard.currentSite}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ])
                  : const Text('Day Off', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ),
                // Today badge
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: const Text('TODAY', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
              ]),
            );
          }),

          const SizedBox(height: 24),
          // Legend
          Wrap(spacing: 16, runSpacing: 8, children: [
            _Legend(label: 'Day Shift (06:00–18:00)', color: AppColors.warning),
            _Legend(label: 'Night Shift (18:00–06:00)', color: AppColors.info),
            _Legend(label: 'Day Off', color: AppColors.textMuted),
          ]),
        ]),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
    ]),
  ));
}

class _Legend extends StatelessWidget {
  final String label;
  final Color color;
  const _Legend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(3), border: Border.all(color: color.withOpacity(0.6)))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
  ]);
}
