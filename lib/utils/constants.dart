import 'package:flutter/material.dart';

// ── Brand colours ──────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFFC9A84C); // Gold
  static const Color primaryLight  = Color(0xFFDFC06E);
  static const Color primaryDark   = Color(0xFF9E7C2E);

  static const Color bgDark        = Color(0xFF0A1628); // Deep navy
  static const Color bgMid         = Color(0xFF0F1E38);
  static const Color surface       = Color(0xFF1A2942);
  static const Color surfaceLight  = Color(0xFF243650);
  static const Color cardBorder    = Color(0xFF2A3F5F);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted     = Color(0xFF607D8B);

  static const Color success       = Color(0xFF4CAF50);
  static const Color warning       = Color(0xFFFF9800);
  static const Color error         = Color(0xFFF44336);
  static const Color info          = Color(0xFF2196F3);

  static const Color divider       = Color(0xFF1E3050);
}

// ── App strings ────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName        = 'Magnum Security';
  static const String tagline        = 'Protecting Zambia\'s Future';
  static const String subTagline     = 'Professional armed & unarmed security services across Lusaka and Zambia.';
  static const String phone          = '+260 21 123 5274';
  static const String whatsapp       = '+260 21 123 5274';
  static const String email          = 'info@magnumsecurity.co.zm';
  static const String address        = 'Plot 11/12B, Bwinjimfumu Road, Rhodes Park, Lusaka';
  static const String licenseZAPS    = 'ZAPS Lic. ZS-2024-0042';
  static const String licensePSAZ    = 'PSAZ Member No. 0178';

  static const String emergencyHotline = 'Emergency: 0800 123 456';
}

// ── Sizing helpers ─────────────────────────────────────────────────────────
class AppSizes {
  AppSizes._();

  static const double paddingXS   = 4.0;
  static const double paddingS    = 8.0;
  static const double paddingM    = 16.0;
  static const double paddingL    = 24.0;
  static const double paddingXL   = 32.0;
  static const double paddingXXL  = 48.0;

  static const double radiusS     = 4.0;
  static const double radiusM     = 8.0;
  static const double radiusL     = 12.0;
  static const double radiusXL    = 16.0;
  static const double radiusXXL   = 24.0;

  static const double desktopBreakpoint = 960.0;
  static const double tabletBreakpoint  = 600.0;

  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= desktopBreakpoint;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= tabletBreakpoint;
  static bool isMobile(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width < tabletBreakpoint;
}

// ── Route names ────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String home              = '/';
  static const String services          = '/services';
  static const String about             = '/about';
  static const String contact           = '/contact';
  static const String quote             = '/quote';
  static const String login             = '/login';
  // Client portal
  static const String clientDashboard   = '/client/dashboard';
  static const String clientIncidents   = '/client/incidents';
  static const String clientPatrol      = '/client/patrol';
  static const String clientBilling     = '/client/billing';
  // Admin portal
  static const String adminDashboard    = '/admin/dashboard';
  static const String adminGuards       = '/admin/guards';
  static const String adminScheduling   = '/admin/scheduling';
  static const String adminSites        = '/admin/sites';
  static const String adminAttendance   = '/admin/attendance';
  static const String adminPayroll      = '/admin/payroll';
  static const String adminMessaging    = '/admin/messaging';
  static const String adminCrm          = '/admin/crm';
  // Admin portal (continued)
  static const String adminAlerts       = '/admin/alerts';
  // Guard portal
  static const String guardDashboard    = '/guard/dashboard';
  static const String guardSchedule     = '/guard/schedule';
  static const String guardAttendance   = '/guard/attendance';
}
