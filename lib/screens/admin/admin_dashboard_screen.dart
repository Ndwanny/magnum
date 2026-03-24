import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/activity_item.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final guards   = MockDataService.guards;
    final sites    = MockDataService.sites;
    final incidents = MockDataService.incidents;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      drawer: !isDesktop ? const _AdminDrawer() : null,
      body: Builder(
        builder: (scaffoldCtx) => Row(
        children: [
          if (isDesktop) const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                AdminTopBar(onMenuTap: isDesktop ? null : () => Scaffold.of(scaffoldCtx).openDrawer()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Operations Dashboard', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                            Text('Real-time overview — Lusaka Operations', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.success.withOpacity(0.3))),
                            child: const Row(children: [
                              Icon(Icons.circle, color: AppColors.success, size: 8),
                              SizedBox(width: 6),
                              Text('Control Room Active', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ]),

                        const SizedBox(height: 28),

                        // Stats grid
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 900 ? 4 : c.maxWidth > 500 ? 2 : 1;
                          return Wrap(
                            spacing: 16, runSpacing: 16,
                            children: [
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: StatCard(title: 'Active Guards', value: '${guards.where((g) => g.status == "Active").length}', subtitle: 'of ${guards.length} total', icon: Icons.people, color: AppColors.success, changePercent: 5.0)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: StatCard(title: 'Client Sites', value: '${sites.length}', subtitle: '${sites.where((s) => s.status == "Active").length} active', icon: Icons.apartment, color: AppColors.primary, changePercent: 12.0)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: StatCard(title: 'Open Incidents', value: '${incidents.where((i) => i.status == "Open" || i.status == "In Progress").length}', subtitle: 'Require attention', icon: Icons.warning_amber, color: AppColors.warning, changePercent: -8.0)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: const StatCard(title: 'Monthly Revenue', value: 'ZMW 485K', subtitle: 'March 2024', icon: Icons.payments, color: AppColors.info, changePercent: 3.0)),
                            ],
                          );
                        }),

                        const SizedBox(height: 32),

                        // Charts row
                        LayoutBuilder(builder: (ctx, c) {
                          if (c.maxWidth > 700) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _IncidentTrendChart()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _ServiceDistributionChart()),
                              ],
                            );
                          }
                          return Column(children: [_IncidentTrendChart(), const SizedBox(height: 16), _ServiceDistributionChart()]);
                        }),

                        const SizedBox(height: 24),

                        // Bottom row
                        LayoutBuilder(builder: (ctx, c) {
                          if (c.maxWidth > 700) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _RecentActivityPanel()),
                                const SizedBox(width: 16),
                                Expanded(child: _GuardStatusPanel()),
                              ],
                            );
                          }
                          return Column(children: [_RecentActivityPanel(), const SizedBox(height: 16), _GuardStatusPanel()]);
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

class AdminTopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const AdminTopBar({this.onMenuTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(color: AppColors.bgMid, border: Border(bottom: BorderSide(color: AppColors.divider))),
    child: Row(children: [
      if (!AppSizes.isDesktop(context))
        IconButton(icon: const Icon(Icons.menu, color: AppColors.textPrimary), onPressed: onMenuTap),
      const Text('Admin Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
      const Spacer(),
      const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
      const SizedBox(width: 16),
      const CircleAvatar(radius: 16, backgroundColor: Color(0x33C9A84C), child: Text('A', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700))),
      const SizedBox(width: 8),
      Builder(builder: (ctx) => TextButton(
        onPressed: () {
          ctx.read<AuthService>().logout();
          Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
        },
        child: const Text('Sign Out', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      )),
    ]),
  );
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar();

  @override
  Widget build(BuildContext context) => Container(
    width: 230,
    color: AppColors.bgMid,
    child: Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: Row(children: const [
          Icon(Icons.shield, color: AppColors.primary, size: 24),
          SizedBox(width: 8),
          Text('MAGNUM', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        ]),
      ),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.divider)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text('OPERATIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      ),
      _AdminNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard, active: true),
      _AdminNavItem(icon: Icons.people_outline, label: 'Guard Management', route: AppRoutes.adminGuards),
      _AdminNavItem(icon: Icons.calendar_month_outlined, label: 'Scheduling', route: AppRoutes.adminScheduling),
      _AdminNavItem(icon: Icons.apartment_outlined, label: 'Client Sites', route: AppRoutes.adminSites),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text('REPORTS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      ),
      _AdminNavItem(icon: Icons.people_outline, label: 'Attendance', route: AppRoutes.adminAttendance),
      _AdminNavItem(icon: Icons.payments_outlined, label: 'Payroll', route: AppRoutes.adminPayroll),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text('COMMUNICATIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      ),
      _AdminNavItem(icon: Icons.chat_outlined, label: 'Messaging & Alerts', route: AppRoutes.adminMessaging),
      _AdminNavItem(icon: Icons.leaderboard_outlined, label: 'CRM Pipeline', route: AppRoutes.adminCrm),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text('WORKFORCE', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      ),
      _AdminNavItem(icon: Icons.fingerprint, label: 'Attendance', route: AppRoutes.adminAttendance),
      _AdminNavItem(icon: Icons.payments_outlined, label: 'Payroll', route: AppRoutes.adminPayroll),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Text('BUSINESS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
      ),
      _AdminNavItem(icon: Icons.bar_chart_outlined, label: 'CRM Pipeline', route: AppRoutes.adminCrm),
      _AdminNavItem(icon: Icons.notifications_active_outlined, label: 'Alerts & SMS', route: AppRoutes.adminAlerts),
      _AdminNavItem(icon: Icons.chat_bubble_outline, label: 'Messaging', route: AppRoutes.adminMessaging),
      _AdminNavItem(icon: Icons.receipt_long_outlined, label: 'Billing', route: AppRoutes.clientBilling),
      _AdminNavItem(icon: Icons.report_outlined, label: 'Incidents', route: AppRoutes.clientIncidents),
      const Spacer(),
      const Divider(color: AppColors.divider),
      _AdminNavItem(icon: Icons.language, label: 'Public Website', route: AppRoutes.home),
      const SizedBox(height: 8),
    ]),
  );
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer();
  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.bgMid,
    child: Column(children: const [
      DrawerHeader(decoration: BoxDecoration(color: AppColors.bgDark), child: Row(children: [Icon(Icons.shield, color: AppColors.primary, size: 32), SizedBox(width: 12), Text('Admin Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700))])),
      _AdminNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard, active: true),
      _AdminNavItem(icon: Icons.people_outline, label: 'Guards', route: AppRoutes.adminGuards),
      _AdminNavItem(icon: Icons.calendar_month_outlined, label: 'Scheduling', route: AppRoutes.adminScheduling),
      _AdminNavItem(icon: Icons.apartment_outlined, label: 'Sites', route: AppRoutes.adminSites),
    ]),
  );
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final bool active;
  const _AdminNavItem({required this.icon, required this.label, required this.route, this.active = false});

  @override
  Widget build(BuildContext context) => Material(
    color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(children: [
          Icon(icon, color: active ? AppColors.primary : AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: active ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    ),
  );
}

// ── Charts ────────────────────────────────────────────────────────────────────
class _IncidentTrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incident Trends (Last 6 months)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Monthly incident count by severity', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 0.5),
                  getDrawingVerticalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 0.5),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5, reservedSize: 28, getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)))),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v, _) {
                    const months = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
                    if (v.toInt() >= 0 && v.toInt() < months.length) {
                      return Text(months[v.toInt()], style: const TextStyle(color: AppColors.textMuted, fontSize: 10));
                    }
                    return const Text('');
                  })),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 12), FlSpot(1, 15), FlSpot(2, 9), FlSpot(3, 18), FlSpot(4, 14), FlSpot(5, 11)],
                    isCurved: true, color: AppColors.primary, barWidth: 2.5, dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.08)),
                  ),
                  LineChartBarData(
                    spots: const [FlSpot(0, 4), FlSpot(1, 7), FlSpot(2, 3), FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 3)],
                    isCurved: true, color: AppColors.error, barWidth: 2, dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.error.withOpacity(0.06)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _ChartLegend(color: AppColors.primary, label: 'All incidents'),
            const SizedBox(width: 16),
            _ChartLegend(color: AppColors.error, label: 'High/Critical'),
          ]),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 16, height: 3, color: color),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
  ]);
}

class _ServiceDistributionChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Distribution', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Sites by service type', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 35, color: AppColors.primary, title: '35%', radius: 50, titleStyle: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                  PieChartSectionData(value: 30, color: AppColors.info, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  PieChartSectionData(value: 20, color: AppColors.success, title: '20%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  PieChartSectionData(value: 15, color: AppColors.warning, title: '15%', radius: 50, titleStyle: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PieLegend(color: AppColors.primary, label: 'Armed + CCTV'),
          _PieLegend(color: AppColors.info, label: 'Armed + Unarmed'),
          _PieLegend(color: AppColors.success, label: 'Unarmed only'),
          _PieLegend(color: AppColors.warning, label: 'Alarm + Patrol'),
        ],
      ),
    );
  }
}

class _PieLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _PieLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
    ]),
  );
}

class _RecentActivityPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const Divider(color: AppColors.divider),
          ActivityItem(icon: Icons.warning_amber, iconColor: AppColors.warning, title: 'Incident filed at Arcades', subtitle: 'Attempted break-in — east entrance', time: '10h ago'),
          ActivityItem(icon: Icons.person_add, iconColor: AppColors.success, title: 'New guard onboarded', subtitle: 'Mwansa Tembo — Levy Junction', time: '1d ago'),
          ActivityItem(icon: Icons.receipt, iconColor: AppColors.primary, title: 'Invoice INV-2024-0042 issued', subtitle: 'ZMW 96,000 — Arcades Investments', time: '2d ago'),
          ActivityItem(icon: Icons.update, iconColor: AppColors.info, title: 'Shift schedule updated', subtitle: 'UTH Complex — March rotation', time: '2d ago'),
          ActivityItem(icon: Icons.check_circle, iconColor: AppColors.success, title: 'Patrol completed at Manda Hill', subtitle: 'Chanda Mwamba — 4/4 checkpoints', time: '3h ago'),
        ],
      ),
    );
  }
}

class _GuardStatusPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final guards = MockDataService.guards;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Guard Status', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.adminGuards), child: const Text('View All', style: TextStyle(fontSize: 12))),
          ]),
          const Divider(color: AppColors.divider),
          ...guards.take(5).map((g) {
            final statusColor = g.status == 'Active' ? AppColors.success : g.status == 'On Leave' ? AppColors.warning : AppColors.textMuted;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(g.name[0], style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('${g.role}  •  ${g.currentSite}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ])),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}
