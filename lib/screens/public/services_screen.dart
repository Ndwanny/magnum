import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';
import '../../widgets/common/custom_footer.dart';
import '../../widgets/common/emergency_fab.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _services = [
    _ServiceData(
      icon: Icons.shield,
      title: 'Armed Security Officers',
      description: 'Our armed security officers are graduates of an intensive 3-month training programme covering tactical response, firearm safety, Zambian law, and customer service. Ideal for banks, cash operations, high-risk retail and residential estates.',
      features: ['ZAPS Grade A certified', 'Licensed firearms', 'Rapid incident response', 'Uniformed and professional', 'Regular refresher training'],
      tag: 'Most Requested',
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.security,
      title: 'Unarmed Security Guards',
      description: 'Professional, visible deterrence for shopping centres, office blocks, schools, hospitality venues and construction sites. Cost-effective and always courteous.',
      features: ['ZAPS Grade C certified', 'Access control', 'Visitor management', 'Loss prevention support', 'Customer-facing roles'],
      tag: null,
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.camera_indoor,
      title: 'CCTV Installation & Monitoring',
      description: 'End-to-end CCTV solutions from site survey and installation to 24/7 remote monitoring from our Lusaka operations centre. We support HD, IP and analogue systems.',
      features: ['Free site survey', 'HD & 4K cameras', '24/7 remote monitoring', 'Cloud & local storage', 'Maintenance contracts'],
      tag: null,
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.notifications_active,
      title: 'Alarm Systems & Response',
      description: 'Design, installation and monitoring of intruder alarm systems with armed response. Panic buttons, motion sensors and perimeter alerts linked directly to our control room.',
      features: ['Armed response within 10 min', 'Panic button installation', 'Motion & perimeter detection', 'Smart mobile alerts', '24/7 monitoring centre'],
      tag: null,
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.event,
      title: 'Event Security',
      description: 'Crowd management, perimeter control and VIP protection for concerts, corporate events, political gatherings, sporting events and private functions.',
      features: ['Crowd management certified', 'Perimeter access control', 'VIP escort services', 'Event risk assessment', 'Plain-clothes officers available'],
      tag: null,
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.directions_car,
      title: 'Mobile Patrols',
      description: 'Scheduled and randomised vehicle patrols for residential estates, industrial parks and commercial properties. All patrols logged via our digital system with GPS tracking.',
      features: ['GPS-tracked patrol vehicles', 'Scheduled & random visits', 'Digital checkpoint logging', 'Immediate incident response', 'Patrol reports via portal'],
      tag: 'New Service',
      tagColor: Colors.blue,
    ),
    _ServiceData(
      icon: Icons.person_pin_circle,
      title: 'VIP & Executive Protection',
      description: 'Discreet, professional close protection for executives, diplomats and high-net-worth individuals. Our protection officers are trained in risk assessment and evasive driving.',
      features: ['Trained protection officers', 'Threat & risk assessments', 'Route planning & recon', 'Evasive driving trained', 'Full-time or as-needed'],
      tag: null,
      tagColor: null,
    ),
    _ServiceData(
      icon: Icons.local_atm,
      title: 'Cash in Transit',
      description: 'Secure transportation of cash, valuables and sensitive documents between business premises, banks and safe storage facilities across Lusaka and major Zambian cities.',
      features: ['Armed escorts', 'Armoured vehicles', 'GPS & real-time tracking', 'Insurance coverage support', 'Flexible scheduling'],
      tag: null,
      tagColor: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(),
      floatingActionButton: const EmergencyFAB(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ServicesHero(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 24, vertical: 48,
              ),
              child: LayoutBuilder(builder: (ctx, c) {
                final cols = c.maxWidth > 800 ? 2 : 1;
                return Wrap(
                  spacing: 20, runSpacing: 20,
                  children: _services.map((s) => SizedBox(
                    width: (c.maxWidth - (cols - 1) * 20) / cols,
                    child: _ServiceDetailCard(data: s),
                  )).toList(),
                );
              }),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }
}

class _ServicesHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgMid]),
    ),
    child: Column(children: const [
      Text('OUR SERVICES', style: TextStyle(color: AppColors.primary, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w700)),
      SizedBox(height: 12),
      Text('Complete Security Solutions', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      SizedBox(height: 12),
      Text('Tailored to your needs. Backed by training, technology and 15+ years of experience.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15), textAlign: TextAlign.center),
    ]),
  );
}

class _ServiceData {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final String? tag;
  final Color? tagColor;

  const _ServiceData({
    required this.icon, required this.title, required this.description,
    required this.features, required this.tag, required this.tagColor,
  });
}

class _ServiceDetailCard extends StatelessWidget {
  final _ServiceData data;
  const _ServiceDetailCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      border: Border.all(color: AppColors.cardBorder, width: 0.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: Colors.black, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(data.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                if (data.tag != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(data.tag!, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                ],
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(data.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
        const SizedBox(height: 16),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 12),
        ...data.features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 15),
            const SizedBox(width: 8),
            Text(f, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
        )),
        const SizedBox(height: 16),
        Builder(builder: (ctx) => ElevatedButton(
          onPressed: () => Navigator.pushNamed(ctx, AppRoutes.quote),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: const Text('Request This Service'),
        )),
      ],
    ),
  );
}
