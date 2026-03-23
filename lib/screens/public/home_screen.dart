import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';
import '../../widgets/common/custom_footer.dart';
import '../../widgets/common/emergency_fab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(),
      floatingActionButton: const EmergencyFAB(),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _HeroSection(),
            _StatsBar(),
            _ServicesSection(),
            _WhyChooseUsSection(),
            _TestimonialsSection(),
            _CtaSection(),
            CustomFooter(),
          ],
        ),
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    final isMobile  = AppSizes.isMobile(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isDesktop ? 580 : 480),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgDark, AppColors.bgMid, const Color(0xFF0F2040)],
        ),
      ),
      child: Stack(
        children: [
          // Gold decorative grid
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Decorative shield
          Positioned(
            right: isDesktop ? 60 : -60,
            top: 40,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.shield, size: isDesktop ? 400 : 300, color: AppColors.primary),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24,
                vertical: 60,
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(flex: 3, child: _HeroContent()),
                        const Expanded(flex: 2, child: _HeroGraphic()),
                      ],
                    )
                  : Column(children: [
                      _HeroContent(),
                      const SizedBox(height: 40),
                      const _HeroGraphic(),
                    ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = AppSizes.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: AppColors.primary, size: 13),
              SizedBox(width: 6),
              Text('ZAPS & PSAZ Licensed', style: TextStyle(
                color: AppColors.primary, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1,
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Protecting\nZambia\'s Future',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 36 : 52,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: const TextSpan(children: [
            TextSpan(text: 'with ', style: TextStyle(color: AppColors.textSecondary, fontSize: 20, fontWeight: FontWeight.w400)),
            TextSpan(text: 'Magnum Security', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text(AppStrings.subTagline, style: TextStyle(
          color: AppColors.textSecondary, fontSize: 16, height: 1.6,
        )),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            Builder(builder: (ctx) => ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(ctx, AppRoutes.quote),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Get a Free Quote'),
            )),
            Builder(builder: (ctx) => OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(ctx, AppRoutes.services),
              icon: const Icon(Icons.security, size: 18),
              label: const Text('Our Services'),
            )),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: const [
            _TrustBadge(icon: Icons.schedule, label: '24/7 Response'),
            SizedBox(width: 20),
            _TrustBadge(icon: Icons.people, label: '500+ Guards'),
            SizedBox(width: 20),
            _TrustBadge(icon: Icons.apartment, label: '200+ Sites'),
          ],
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.primary, size: 14),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ],
  );
}

class _HeroGraphic extends StatelessWidget {
  const _HeroGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
          ),
          // Inner ring
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.5),
            ),
          ),
          // Core card
          Container(
            width: 170, height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primary.withOpacity(0.2), AppColors.surface],
              ),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, color: AppColors.primary, size: 56),
                SizedBox(height: 6),
                Text('MAGNUM', style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 13,
                  fontWeight: FontWeight.w800, letterSpacing: 2,
                )),
                Text('SECURITY', style: TextStyle(
                  color: AppColors.primary, fontSize: 9,
                  fontWeight: FontWeight.w600, letterSpacing: 3,
                )),
              ],
            ),
          ),
          // Orbit icons
          _OrbitIcon(angle: 0,    radius: 120, icon: Icons.camera_alt,  label: 'CCTV'),
          _OrbitIcon(angle: 90,   radius: 120, icon: Icons.security,    label: 'Guards'),
          _OrbitIcon(angle: 180,  radius: 120, icon: Icons.notifications_active, label: 'Alarms'),
          _OrbitIcon(angle: 270,  radius: 120, icon: Icons.directions_car, label: 'Patrols'),
        ],
      ),
    );
  }
}

class _OrbitIcon extends StatelessWidget {
  final double angle;
  final double radius;
  final IconData icon;
  final String label;
  const _OrbitIcon({required this.angle, required this.radius, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final rad = angle * 3.14159265 / 180;
    final x = radius * (angle == 0 ? 1 : angle == 180 ? -1 : 0);
    final y = radius * (angle == 90 ? 1 : angle == 270 ? -1 : 0);
    return Transform.translate(
      offset: Offset(x.toDouble(), y.toDouble()),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(
            color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1,
          )),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Stats Bar ───────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 16, runSpacing: 16,
        children: const [
          _StatBadge(value: '500+', label: 'Trained Guards'),
          _StatBadge(value: '200+', label: 'Client Sites'),
          _StatBadge(value: '15+',  label: 'Years in Business'),
          _StatBadge(value: '24/7', label: 'Operations Center'),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(
        color: Colors.black, fontSize: 28, fontWeight: FontWeight.w800,
      )),
      Text(label, style: const TextStyle(
        color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500,
      )),
    ],
  );
}

// ─── Services Preview ────────────────────────────────────────────────────────
class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  static const _services = [
    {'icon': Icons.shield, 'title': 'Armed Security', 'desc': 'Professionally trained armed officers for high-risk environments.', 'tag': 'Most Popular'},
    {'icon': Icons.security, 'title': 'Unarmed Guards', 'desc': 'Cost-effective security presence for retail, offices and events.', 'tag': null},
    {'icon': Icons.camera_indoor, 'title': 'CCTV & Monitoring', 'desc': 'Installation, maintenance and 24/7 remote monitoring services.', 'tag': null},
    {'icon': Icons.notifications_active, 'title': 'Alarm Systems', 'desc': 'Intruder detection, panic buttons and immediate response.', 'tag': null},
    {'icon': Icons.event, 'title': 'Event Security', 'desc': 'Crowd control and perimeter management for any event size.', 'tag': null},
    {'icon': Icons.directions_car, 'title': 'Mobile Patrols', 'desc': 'Scheduled and random vehicle patrols for your properties.', 'tag': 'New'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      color: AppColors.bgMid,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 64,
      ),
      child: Column(
        children: [
          _SectionHeader(tag: 'WHAT WE OFFER', title: 'Comprehensive Security Services', subtitle: 'From armed officers to intelligent surveillance — we have every security need covered for Lusaka businesses.'),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final cols = constraints.maxWidth > 800 ? 3 : constraints.maxWidth > 500 ? 2 : 1;
              return Wrap(
                spacing: 16, runSpacing: 16,
                children: _services.map((s) {
                  return SizedBox(
                    width: (constraints.maxWidth - (cols - 1) * 16) / cols,
                    child: _ServiceCard(
                      icon: s['icon'] as IconData,
                      title: s['title'] as String,
                      desc: s['desc'] as String,
                      tag: s['tag'] as String?,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          Builder(builder: (ctx) => OutlinedButton(
            onPressed: () => Navigator.pushNamed(ctx, AppRoutes.services),
            child: const Text('View All Services'),
          )),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String? tag;
  const _ServiceCard({required this.icon, required this.title, required this.desc, this.tag});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.surface : AppColors.bgDark,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          border: Border.all(
            color: _hovered ? AppColors.primary : AppColors.cardBorder,
            width: _hovered ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Icon(widget.icon, color: AppColors.primary, size: 24),
                ),
                if (widget.tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Text(widget.tag!, style: const TextStyle(
                      color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600,
                    )),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.title, style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600,
            )),
            const SizedBox(height: 6),
            Text(widget.desc, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 13, height: 1.5,
            )),
            const SizedBox(height: 16),
            Row(
              children: const [
                Text('Learn more', style: TextStyle(
                  color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600,
                )),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: AppColors.primary, size: 13),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Why Choose Us ───────────────────────────────────────────────────────────
class _WhyChooseUsSection extends StatelessWidget {
  const _WhyChooseUsSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      color: AppColors.bgDark,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          _SectionHeader(tag: 'WHY MAGNUM', title: 'Zambia\'s Most Trusted Security Company', subtitle: 'Fully licensed, extensively trained and always responsive.'),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 700 ? 2 : 1;
            return Wrap(
              spacing: 16, runSpacing: 16,
              children: [
                _WhyCard(icon: Icons.verified_user, title: 'Fully Licensed & Compliant', desc: 'Registered with ZAPS (Zambia Association of Professional Security) and PSAZ. All officers certified.', width: (c.maxWidth - (cols - 1) * 16) / cols),
                _WhyCard(icon: Icons.psychology, title: 'Professionally Trained', desc: 'Every guard undergoes rigorous training in security protocols, first aid, conflict resolution and Zambia law.', width: (c.maxWidth - (cols - 1) * 16) / cols),
                _WhyCard(icon: Icons.schedule, title: '24/7 Operations Centre', desc: 'Our Lusaka control room monitors all sites around the clock. Rapid response within minutes of any incident.', width: (c.maxWidth - (cols - 1) * 16) / cols),
                _WhyCard(icon: Icons.smartphone, title: 'Digital Reporting', desc: 'Real-time incident reports and patrol logs delivered to clients via our secure online portal.', width: (c.maxWidth - (cols - 1) * 16) / cols),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final double width;
  const _WhyCard({required this.icon, required this.title, required this.desc, required this.width});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Testimonials ────────────────────────────────────────────────────────────
class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  static const _testimonials = [
    {'name': 'Mwangi Ochieng', 'role': 'Security Manager, Manda Hill Mall', 'text': 'Magnum Security has been our security partner for 5 years. Their guards are professional, well-trained and responsive. Incident reports through their portal save us hours of admin work.'},
    {'name': 'Thandiwe Dube', 'role': 'Operations Director, Arcades Investments', 'text': 'Switching to Magnum was one of the best decisions we made. The 24/7 control room gives us complete peace of mind and their CCTV monitoring is outstanding.'},
    {'name': 'Chipasha Mutale', 'role': 'Facilities Manager, UTH Complex', 'text': 'For a sensitive environment like ours, we need the best. Magnum\'s armed officers are disciplined, courteous and handle challenging situations with remarkable professionalism.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      color: AppColors.bgMid,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          _SectionHeader(tag: 'CLIENT VOICES', title: 'Trusted by Lusaka\'s Leading Organisations'),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 800 ? 3 : 1;
            return Wrap(
              spacing: 16, runSpacing: 16,
              children: _testimonials.map((t) => SizedBox(
                width: (c.maxWidth - (cols - 1) * 16) / cols,
                child: _TestimonialCard(name: t['name']!, role: t['role']!, text: t['text']!),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name, role, text;
  const _TestimonialCard({required this.name, required this.role, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.bgDark,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: List.generate(5, (_) => const Icon(Icons.star, color: AppColors.primary, size: 14))),
        const SizedBox(height: 16),
        Text('"$text"', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6, fontStyle: FontStyle.italic)),
        const SizedBox(height: 16),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(role, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    ),
  );
}

// ─── CTA Banner ──────────────────────────────────────────────────────────────
class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 48),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF8B6020), AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Ready to Secure Your Business?', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('Get a customised security proposal within 24 hours — no obligation.', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 15)),
          const SizedBox(height: 28),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            Builder(builder: (ctx) => ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(ctx, AppRoutes.quote),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: AppColors.primary),
              icon: const Icon(Icons.description, size: 18),
              label: const Text('Request Free Quote'),
            )),
            Builder(builder: (ctx) => OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(ctx, AppRoutes.contact),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: const BorderSide(color: Colors.black)),
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call Us Today'),
            )),
          ]),
        ],
      ),
    );
  }
}

// ─── Shared Section Header ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String? tag;
  final String title;
  final String? subtitle;
  const _SectionHeader({this.tag, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (tag != null) ...[
        Text(tag!, style: const TextStyle(
          color: AppColors.primary, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 2,
        )),
        const SizedBox(height: 8),
      ],
      Text(title, textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[
        const SizedBox(height: 12),
        Text(subtitle!, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6)),
      ],
    ],
  );
}
