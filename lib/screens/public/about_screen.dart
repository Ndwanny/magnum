import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';
import '../../widgets/common/custom_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _AboutHero(),
            _MissionSection(),
            _TeamSection(),
            _LicensingSection(),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgMid])),
    child: Column(children: const [
      Text('OUR STORY', style: TextStyle(color: AppColors.primary, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w700)),
      SizedBox(height: 12),
      Text('About Magnum Security', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      SizedBox(height: 12),
      Text('Founded in Lusaka in 2008. Built on integrity, professionalism and community.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15), textAlign: TextAlign.center),
    ]),
  );
}

class _MissionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 64),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: _StoryText()), const SizedBox(width: 64), Expanded(child: _MissionCards())],
            )
          : Column(children: [_StoryText(), const SizedBox(height: 40), _MissionCards()]),
    );
  }
}

class _StoryText extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text('Our Story', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      SizedBox(height: 12),
      Text('From Lusaka - for Zambia', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
      SizedBox(height: 16),
      Text('Magnum Security was founded in 2008 by a team of former Zambia Police and Defence Force officers with a vision: to raise the standard of professional security services in Zambia.\n\nOver 15 years, we have grown from a team of 20 guards serving 5 sites in Lusaka to over 500 certified officers covering 200+ client sites across Zambia.\n\nWe believe every Zambian business and family deserves world-class security. That is why we invest continuously in our people, technology and processes so you can invest in yours.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.8)),
    ],
  );
}

class _MissionCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _MissionCard(icon: Icons.flag, color: AppColors.primary, title: 'Our Mission', body: 'To provide Zambia\'s most professional, responsive and trustworthy security services, protecting people, property and peace of mind.'),
      const SizedBox(height: 16),
      _MissionCard(icon: Icons.visibility, color: AppColors.info, title: 'Our Vision', body: 'To be Zambia\'s number-one security provider by 2030, known for excellence in service, integrity in operations and positive community impact.'),
      const SizedBox(height: 16),
      _MissionCard(icon: Icons.favorite, color: AppColors.error, title: 'Our Values', body: 'Integrity. Professionalism. Community. Vigilance. Respect. These five values guide every decision and action at Magnum Security.'),
    ],
  );
}

class _MissionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _MissionCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder, width: 0.5),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
        ])),
      ],
    ),
  );
}

class _TeamSection extends StatelessWidget {
  static const _team = [
    {'name': 'Chisomo Banda', 'role': 'Managing Director', 'bio': 'Former ZPS Superintendent with 20 years of experience. Founded Magnum in 2008.'},
    {'name': 'Namukolo Phiri', 'role': 'Operations Director', 'bio': 'Oversees all field operations, scheduling and quality assurance for 200+ sites.'},
    {'name': 'Mulenga Sata', 'role': 'Training Manager', 'bio': 'Designs and delivers all guard training programmes, certified by ZAPS.'},
    {'name': 'Chilufya Mumba', 'role': 'Technology Officer', 'bio': 'Leads the digital transformation of Magnum\'s operations and client portal.'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      color: AppColors.bgMid,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          const Text('LEADERSHIP', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Our Leadership Team', style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 40),
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 800 ? 4 : c.maxWidth > 500 ? 2 : 1;
            return Wrap(
              spacing: 16, runSpacing: 16,
              children: _team.map((t) => SizedBox(
                width: (c.maxWidth - (cols - 1) * 16) / cols,
                child: _TeamCard(name: t['name']!, role: t['role']!, bio: t['bio']!),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final String name, role, bio;
  const _TeamCard({required this.name, required this.role, required this.bio});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Column(children: [
      CircleAvatar(
        radius: 32,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: Text(name[0], style: const TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 12),
      Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      Text(role, style: const TextStyle(color: AppColors.primary, fontSize: 12), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(bio, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.5), textAlign: TextAlign.center),
    ]),
  );
}

class _LicensingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 64),
      child: Column(children: [
        const Text('COMPLIANCE', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Licensed & Regulated', style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
        const SizedBox(height: 32),
        Wrap(spacing: 20, runSpacing: 20, alignment: WrapAlignment.center, children: [
          _LicenseBadge(acronym: 'ZAPS', name: 'Zambia Association of Professional Security', number: AppStrings.licenseZAPS),
          _LicenseBadge(acronym: 'PSAZ', name: 'Private Security Association of Zambia', number: AppStrings.licensePSAZ),
          _LicenseBadge(acronym: 'ZRA', name: 'Zambia Revenue Authority — Tax Compliant', number: 'TPIN: 1003456789'),
        ]),
      ]),
    );
  }
}

class _LicenseBadge extends StatelessWidget {
  final String acronym, name, number;
  const _LicenseBadge({required this.acronym, required this.name, required this.number});

  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(acronym, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1))),
      ),
      const SizedBox(height: 12),
      Text(name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4), textAlign: TextAlign.center),
      const SizedBox(height: 6),
      Text(number, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}
