import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  const AdminTopBar({super.key, this.title = 'Admin Portal'});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.bgMid,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0x33C9A84C),
            child: Text('A', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              context.read<AuthService>().logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 230,
    color: AppColors.bgMid,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: const Row(
            children: [
              Icon(Icons.shield, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('MAGNUM', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider(color: AppColors.divider)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(alignment: Alignment.centerLeft, child: Text('OPERATIONS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
        ),
        const _AdminNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard),
        const _AdminNavItem(icon: Icons.people_outline, label: 'Guard Management', route: AppRoutes.adminGuards),
        const _AdminNavItem(icon: Icons.calendar_month_outlined, label: 'Scheduling', route: AppRoutes.adminScheduling),
        const _AdminNavItem(icon: Icons.apartment_outlined, label: 'Client Sites', route: AppRoutes.adminSites),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(alignment: Alignment.centerLeft, child: Text('REPORTS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
        ),
        const _AdminNavItem(icon: Icons.fingerprint, label: 'Attendance', route: AppRoutes.adminAttendance),
        const _AdminNavItem(icon: Icons.payments_outlined, label: 'Payroll', route: AppRoutes.adminPayroll),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(alignment: Alignment.centerLeft, child: Text('BUSINESS', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5))),
        ),
        const _AdminNavItem(icon: Icons.bar_chart_outlined, label: 'CRM Pipeline', route: AppRoutes.adminCrm),
        const _AdminNavItem(icon: Icons.notifications_active_outlined, label: 'Alerts & SMS', route: AppRoutes.adminAlerts),
        const _AdminNavItem(icon: Icons.chat_bubble_outline, label: 'Messaging', route: AppRoutes.adminMessaging),
        const Spacer(),
        const Divider(color: AppColors.divider),
        const _AdminNavItem(icon: Icons.language, label: 'Public Website', route: AppRoutes.home),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
    backgroundColor: AppColors.bgMid,
    child: Column(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(color: AppColors.bgDark),
          child: Row(
            children: const [
              Icon(Icons.shield, color: AppColors.primary, size: 32),
              SizedBox(width: 12),
              Text('Admin Portal', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const _AdminNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard),
        const _AdminNavItem(icon: Icons.people_outline, label: 'Guards', route: AppRoutes.adminGuards),
        const _AdminNavItem(icon: Icons.calendar_month_outlined, label: 'Scheduling', route: AppRoutes.adminScheduling),
        const _AdminNavItem(icon: Icons.apartment_outlined, label: 'Sites', route: AppRoutes.adminSites),
        const _AdminNavItem(icon: Icons.fingerprint, label: 'Attendance', route: AppRoutes.adminAttendance),
        const _AdminNavItem(icon: Icons.bar_chart_outlined, label: 'CRM Pipeline', route: AppRoutes.adminCrm),
        const _AdminNavItem(icon: Icons.notifications_active_outlined, label: 'Alerts', route: AppRoutes.adminAlerts),
        const Spacer(),
        const Divider(color: AppColors.divider),
        const _AdminNavItem(icon: Icons.language, label: 'Public Website', route: AppRoutes.home),
        const SizedBox(height: 8),
      ],
    ),
  );
}

class _AdminNavItem extends StatelessWidget {
  final IconData icon;
  final String label, route;
  final bool active;
  const _AdminNavItem({required this.icon, required this.label, required this.route, this.active = false});

  @override
  Widget build(BuildContext context) {
    // Basic active state check by current route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isCurrentlyActive = active || currentRoute == route;

    return Material(
      color: isCurrentlyActive ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
          if (currentRoute != route) {
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(icon, color: isCurrentlyActive ? AppColors.primary : AppColors.textMuted, size: 18),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: isCurrentlyActive ? AppColors.primary : AppColors.textSecondary, fontSize: 13, fontWeight: isCurrentlyActive ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}
