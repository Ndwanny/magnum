import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/constants.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/dashboard/activity_item.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});
  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final isDesktop = AppSizes.isDesktop(context);
    final incidents = MockDataService.incidents;
    final patrols   = MockDataService.patrolLogs;

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
                ClientTopBar(user: auth.currentUser, onMenuTap: isDesktop ? null : () => Scaffold.of(scaffoldCtx).openDrawer()),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back, ${auth.currentUser?.name ?? "Client"}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        const Text('Manda Hill Mall  •  Contract Active', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                        const SizedBox(height: 28),

                        // Stats
                        LayoutBuilder(builder: (ctx, c) {
                          final cols = c.maxWidth > 700 ? 4 : c.maxWidth > 400 ? 2 : 1;
                          return Wrap(
                            spacing: 16, runSpacing: 16,
                            children: [
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: const StatCard(title: 'Guards On Duty', value: '12', subtitle: 'As of right now', icon: Icons.people, color: AppColors.success, changePercent: 0)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: StatCard(title: 'Open Incidents', value: '${incidents.where((i) => i.status == "Open" || i.status == "In Progress").length}', subtitle: 'Requires attention', icon: Icons.warning_amber, color: AppColors.warning)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: StatCard(title: 'Patrols Today', value: '${patrols.length}', subtitle: '${patrols.where((p) => p.status == "Completed").length} completed', icon: Icons.directions_walk, color: AppColors.info)),
                              SizedBox(width: (c.maxWidth - (cols - 1) * 16) / cols, child: const StatCard(title: 'Contract Status', value: 'Active', subtitle: 'Expires Dec 2025', icon: Icons.verified, color: AppColors.primary)),
                            ],
                          );
                        }),

                        const SizedBox(height: 32),

                        // Panels row
                        LayoutBuilder(builder: (ctx, c) {
                          if (c.maxWidth > 700) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _RecentIncidents()),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _PatrolSummary()),
                              ],
                            );
                          }
                          return Column(children: [_RecentIncidents(), const SizedBox(height: 16), _PatrolSummary()]);
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

class ClientTopBar extends StatelessWidget {
  final AuthUser? user;
  final VoidCallback? onMenuTap;
  const ClientTopBar({this.user, this.onMenuTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(
      color: AppColors.bgMid,
      border: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    child: Row(
      children: [
        if (!AppSizes.isDesktop(context))
          IconButton(icon: const Icon(Icons.menu, color: AppColors.textPrimary), onPressed: onMenuTap),
        const Text('Client Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const Spacer(),
        const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(user?.name.substring(0, 1) ?? 'C', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Builder(builder: (ctx) => TextButton(
          onPressed: () {
            ctx.read<AuthService>().logout();
            Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
          },
          child: const Text('Sign Out', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        )),
      ],
    ),
  );
}

class ClientSidebar extends StatelessWidget {
  const ClientSidebar();

  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    color: AppColors.bgMid,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(children: const [
            Icon(Icons.shield, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('MAGNUM', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          ]),
        ),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 8),
        _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.clientDashboard, active: true),
        _SidebarItem(icon: Icons.report_outlined, label: 'Incident Reports', route: AppRoutes.clientIncidents),
        _SidebarItem(icon: Icons.route_outlined, label: 'Patrol Logs', route: AppRoutes.clientPatrol),
        _SidebarItem(icon: Icons.receipt_long_outlined, label: 'Billing', route: AppRoutes.clientBilling),
        const Spacer(),
        const Divider(color: AppColors.divider),
        Builder(builder: (ctx) => _SidebarItem(icon: Icons.logout, label: 'Sign Out', route: '', onTap: () {
          ctx.read<AuthService>().logout();
          Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
        })),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class ClientDrawer extends StatelessWidget {
  const ClientDrawer();

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.bgMid,
    child: Column(children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: AppColors.bgDark),
        child: Row(children: [
          Icon(Icons.shield, color: AppColors.primary, size: 32),
          SizedBox(width: 12),
          Text('Client Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
      _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.clientDashboard),
      _SidebarItem(icon: Icons.report_outlined, label: 'Incident Reports', route: AppRoutes.clientIncidents),
      _SidebarItem(icon: Icons.route_outlined, label: 'Patrol Logs', route: AppRoutes.clientPatrol),
      _SidebarItem(icon: Icons.receipt_long_outlined, label: 'Billing', route: AppRoutes.clientBilling),
      const Spacer(),
      const Divider(color: AppColors.divider),
      Builder(builder: (ctx) => _SidebarItem(icon: Icons.logout, label: 'Sign Out', route: '', onTap: () {
        ctx.read<AuthService>().logout();
        Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.home, (_) => false);
      })),
      const SizedBox(height: 8),
    ]),
  );
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final bool active;
  final VoidCallback? onTap;
  const _SidebarItem({required this.icon, required this.label, required this.route, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: active ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap ?? () => Navigator.pushNamed(context, route),
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

class _RecentIncidents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final incidents = MockDataService.incidents.take(4).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Incidents', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.clientIncidents),
                child: const Text('View All', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: AppColors.divider),
          ...incidents.map((inc) {
            final Color col = inc.severity == 'Critical' ? AppColors.error : inc.severity == 'High' ? AppColors.warning : inc.severity == 'Medium' ? AppColors.info : AppColors.success;
            return ActivityItem(
              icon: Icons.warning_amber,
              iconColor: col,
              title: inc.title,
              subtitle: '${inc.site}  •  ${inc.status}',
              time: _fmt(inc.reportedAt),
            );
          }),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _PatrolSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final logs = MockDataService.patrolLogs;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patrol Activity', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          const Divider(color: AppColors.divider),
          ...logs.map((log) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (log.status == 'Completed' ? AppColors.success : log.status == 'Ongoing' ? AppColors.info : AppColors.error).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(log.status, style: TextStyle(
                    color: log.status == 'Completed' ? AppColors.success : log.status == 'Ongoing' ? AppColors.info : AppColors.error,
                    fontSize: 10, fontWeight: FontWeight.w700,
                  )),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(log.guardName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
              ]),
              const SizedBox(height: 4),
              Text('${log.checkpoints.length} checkpoints  •  ${log.site}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ]),
          )),
        ],
      ),
    );
  }
}
