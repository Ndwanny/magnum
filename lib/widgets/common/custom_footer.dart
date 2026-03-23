import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Container(
      color: AppColors.bgMid,
      child: Column(
        children: [
          Container(height: 1, color: AppColors.primary.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 20,
              vertical: 40,
            ),
            child: isDesktop ? _DesktopFooter() : _MobileFooter(),
          ),
          Container(
            color: AppColors.bgDark,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2024 Magnum Security. All rights reserved.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                Text(
                  '${AppStrings.licenseZAPS}  |  ${AppStrings.licensePSAZ}',
                  style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _BrandColumn()),
        const SizedBox(width: 48),
        Expanded(child: _LinksColumn(title: 'Services', links: ['Armed Security', 'Unarmed Security', 'CCTV & Alarms', 'Event Security', 'VIP Protection', 'Cash in Transit'])),
        Expanded(child: _LinksColumn(title: 'Company', links: ['About Us', 'Contact', 'Get a Quote', 'Careers', 'Client Portal'])),
        Expanded(child: _ContactColumn()),
      ],
    );
  }
}

class _MobileFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BrandColumn(),
        const SizedBox(height: 32),
        _ContactColumn(),
      ],
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.shield, color: Colors.black, size: 18)),
        const SizedBox(width: 8),
        Text('MAGNUM SECURITY', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.5)),
      ]),
      const SizedBox(height: 12),
      Text(AppStrings.tagline, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      const Text("Zambia\'s trusted security partner since 2008.\nLicensed, trained and committed to your safety.", style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.6)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emergency, color: AppColors.error, size: 14),
            SizedBox(width: 6),
            Text(AppStrings.emergencyHotline, style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
  );
}

class _LinksColumn extends StatelessWidget {
  final String title;
  final List<String> links;
  const _LinksColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 12),
      ...links.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      )),
    ],
  );
}

class _ContactColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Contact', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 12),
      _ContactItem(icon: Icons.phone, text: AppStrings.phone),
      _ContactItem(icon: Icons.email, text: AppStrings.email),
      _ContactItem(icon: Icons.location_on, text: AppStrings.address),
      _ContactItem(icon: Icons.chat, text: 'WhatsApp: ${AppStrings.whatsapp}'),
    ],
  );
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 13),
        const SizedBox(width: 8),
        Flexible(child: Text(text, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
      ],
    ),
  );
}
