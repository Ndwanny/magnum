import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'services/auth_service.dart';
import 'services/guard_shift_service.dart';

import 'screens/public/home_screen.dart';
import 'screens/public/services_screen.dart';
import 'screens/public/about_screen.dart';
import 'screens/public/contact_screen.dart';
import 'screens/public/quote_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_dashboard_screen.dart';
import 'screens/client/incidents_screen.dart';
import 'screens/client/patrol_logs_screen.dart';
import 'screens/client/billing_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/guards_screen.dart';
import 'screens/admin/scheduling_screen.dart';
import 'screens/admin/sites_screen.dart';
import 'screens/admin/attendance_screen.dart';
import 'screens/admin/payroll_screen.dart';
import 'screens/admin/crm_screen.dart';
import 'screens/admin/messaging_screen.dart';
import 'screens/admin/alerts_screen.dart';
import 'screens/guard/guard_dashboard_screen.dart';
import 'screens/guard/guard_schedule_screen.dart';
import 'screens/guard/guard_attendance_screen.dart';

class MagnumSecurityApp extends StatelessWidget {
  const MagnumSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..restoreSession()),
        ChangeNotifierProvider(create: (_) => GuardShiftService()..load()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case AppRoutes.home:
              page = const HomeScreen();
              break;
            case AppRoutes.services:
              page = const ServicesScreen();
              break;
            case AppRoutes.about:
              page = const AboutScreen();
              break;
            case AppRoutes.contact:
              page = const ContactScreen();
              break;
            case AppRoutes.quote:
              page = const QuoteScreen();
              break;
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.clientDashboard:
              page = const ClientDashboardScreen();
              break;
            case AppRoutes.clientIncidents:
              page = const IncidentsScreen();
              break;
            case AppRoutes.clientPatrol:
              page = const PatrolLogsScreen();
              break;
            case AppRoutes.clientBilling:
              page = const BillingScreen();
              break;
            case AppRoutes.adminDashboard:
              page = const AdminDashboardScreen();
              break;
            case AppRoutes.adminGuards:
              page = const AdminGuardsScreen();
              break;
            case AppRoutes.adminScheduling:
              page = const AdminSchedulingScreen();
              break;
            case AppRoutes.adminSites:
              page = const AdminSitesScreen();
              break;
            case AppRoutes.adminAttendance:
              page = const AdminAttendanceScreen();
              break;
            case AppRoutes.adminPayroll:
              page = const AdminPayrollScreen();
              break;
            case AppRoutes.adminMessaging:
              page = const AdminMessagingScreen();
              break;
            case AppRoutes.adminCrm:
              page = const AdminCrmScreen();
              break;
            case AppRoutes.guardDashboard:
              page = const GuardDashboardScreen();
              break;
            case AppRoutes.guardSchedule:
              page = const GuardScheduleScreen();
              break;
            case AppRoutes.guardAttendance:
              page = const GuardAttendanceScreen();
              break;
            case AppRoutes.adminAlerts:
              page = const AdminAlertsScreen();
              break;
            default:
              page = const HomeScreen();
          }
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (_, __, ___) => page,
            transitionDuration: const Duration(milliseconds: 180),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }
}
