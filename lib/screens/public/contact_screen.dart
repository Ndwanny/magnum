import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/email_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';
import '../../widgets/common/custom_footer.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ContactHero(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 48),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _contactForm()),
                        const SizedBox(width: 48),
                        Expanded(child: _ContactInfo()),
                      ],
                    )
                  : Column(children: [_ContactInfo(), const SizedBox(height: 32), _contactForm()]),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _contactForm() {
    if (_submitted) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Column(children: const [
          Icon(Icons.check_circle, color: AppColors.success, size: 56),
          SizedBox(height: 16),
          Text('Message Sent!', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Thank you for reaching out. Our team will respond within 2 hours during business hours.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6), textAlign: TextAlign.center),
        ]),
      );
    }

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send us a Message', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            _Field(ctrl: _nameCtrl,    label: 'Full Name',          hint: 'John Banda', icon: Icons.person),
            const SizedBox(height: 16),
            _Field(ctrl: _emailCtrl,   label: 'Email Address',      hint: 'john@company.zm', icon: Icons.email, type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _Field(ctrl: _phoneCtrl,   label: 'Phone / WhatsApp',   hint: '+260 97X XXX XXX', icon: Icons.phone, type: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Tell us about your security needs...',
                prefixIcon: Icon(Icons.message),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v?.isEmpty ?? true) ? 'Please enter a message' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Save to Supabase + send email notification
    try {
      await DatabaseService.submitContact(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
      );
      await EmailService.sendContactNotification(
        fromName: _nameCtrl.text.trim(),
        fromEmail: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        message: _messageCtrl.text.trim(),
      );
    } catch (_) {
      // Don't block UI on email/db failure
    }
    setState(() => _submitted = true);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final TextInputType? type;
  const _Field({required this.ctrl, required this.label, required this.hint, required this.icon, this.type});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: type,
    decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon)),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Required';
      if (type == TextInputType.emailAddress) {
        final emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
        if (!emailRe.hasMatch(v)) return 'Enter a valid email address';
      }
      if (type == TextInputType.phone && v.replaceAll(RegExp(r'\D'), '').length < 8) {
        return 'Enter a valid phone number';
      }
      return null;
    },
  );
}

class _ContactHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgMid])),
    child: Column(children: const [
      Text('GET IN TOUCH', style: TextStyle(color: AppColors.primary, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w700)),
      SizedBox(height: 12),
      Text('Contact Magnum Security', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      SizedBox(height: 12),
      Text('We respond within 2 hours. Emergency? Call our 24/7 hotline.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15), textAlign: TextAlign.center),
    ]),
  );
}

class _ContactInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Contact Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 20),
      _InfoRow(icon: Icons.phone, color: AppColors.success, label: 'Phone', value: AppStrings.phone),
      _InfoRow(icon: Icons.chat, color: AppColors.success, label: 'WhatsApp', value: AppStrings.whatsapp),
      _InfoRow(icon: Icons.email, color: AppColors.info, label: 'Email', value: AppStrings.email),
      _InfoRow(icon: Icons.location_on, color: AppColors.primary, label: 'Office', value: AppStrings.address),
      _InfoRow(icon: Icons.schedule, color: AppColors.warning, label: 'Business Hours', value: 'Mon-Fri: 08:00-17:00 | Sat: 09:00-13:00'),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Row(children: [
            Icon(Icons.emergency, color: AppColors.error, size: 16),
            SizedBox(width: 6),
            Text('EMERGENCY 24/7', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ]),
          SizedBox(height: 4),
          Text('0800 123 456', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Free to call — armed response available', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ]),
      ),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _InfoRow({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      ]),
    ]),
  );
}
