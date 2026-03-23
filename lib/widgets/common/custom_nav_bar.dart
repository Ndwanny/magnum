import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showAuthButtons;

  const CustomNavBar({super.key, this.showAuthButtons = true});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? AppSizes.paddingXXL : AppSizes.paddingM,
        ),
        child: Row(
          children: [
            // Logo
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (_) => false),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    ),
                    child: const Icon(Icons.shield, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MAGNUM', style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 14,
                        fontWeight: FontWeight.w800, letterSpacing: 2,
                      )),
                      Text('SECURITY', style: TextStyle(
                        color: AppColors.primary, fontSize: 10,
                        fontWeight: FontWeight.w600, letterSpacing: 3,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (isDesktop) ...[
              _NavLink(label: 'Services', route: AppRoutes.services),
              _NavLink(label: 'About', route: AppRoutes.about),
              _NavLink(label: 'Contact', route: AppRoutes.contact),
              const SizedBox(width: 8),
              if (showAuthButtons) ...[
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Client Login'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.quote),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text('Get a Quote'),
                ),
              ],
            ] else
              IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String route;
  const _NavLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(label, style: const TextStyle(
        color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500,
      )),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgMid,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.bgDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.shield, color: AppColors.primary, size: 36),
                SizedBox(height: 8),
                Text('MAGNUM SECURITY', style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                )),
              ],
            ),
          ),
          _DrawerItem(label: 'Home', icon: Icons.home_outlined, route: AppRoutes.home),
          _DrawerItem(label: 'Services', icon: Icons.security_outlined, route: AppRoutes.services),
          _DrawerItem(label: 'About', icon: Icons.info_outlined, route: AppRoutes.about),
          _DrawerItem(label: 'Contact', icon: Icons.phone_outlined, route: AppRoutes.contact),
          const Divider(color: AppColors.divider),
          _DrawerItem(label: 'Client Login', icon: Icons.login_outlined, route: AppRoutes.login),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.quote),
              child: const Text('Get a Free Quote'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _DrawerItem({required this.label, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.textSecondary, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );
}
