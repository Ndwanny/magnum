import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/email_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';
import '../../widgets/common/custom_footer.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  int _step = 0;
  bool _submitted = false;
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  final _nameCtrl         = TextEditingController();
  final _companyCtrl      = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _addressCtrl      = TextEditingController();
  final _notesCtrl        = TextEditingController();
  String _selectedService = 'Armed Security';
  int _guards = 2;

  final _services = ['Armed Security', 'Unarmed Guards', 'CCTV & Monitoring', 'Alarm System', 'Event Security', 'Mobile Patrols', 'VIP Protection', 'Cash in Transit', 'Multiple Services'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppSizes.isDesktop(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _QuoteHero(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 200 : 24, vertical: 48),
              child: _submitted ? _SuccessView() : _formContent(),
            ),
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _submitQuote() async {
    try {
      await DatabaseService.submitQuote(
        name: _nameCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        serviceType: _selectedService,
        guardsNeeded: _guards,
        siteAddress: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );
      await EmailService.sendQuoteNotification(
        name: _nameCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        serviceType: _selectedService,
        guardsNeeded: _guards,
        siteAddress: _addressCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );
    } catch (_) {
      // Don't block UI on email/db failure
    }
    setState(() => _submitted = true);
  }

  Widget _formContent() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          _StepIndicator(currentStep: _step),
          const SizedBox(height: 32),
          if (_step == 0) Form(key: _step1Key, child: _StepOne()),
          if (_step == 1) Form(key: _step2Key, child: _StepTwo(selectedService: _selectedService, guards: _guards, onServiceChanged: (v) => setState(() => _selectedService = v), onGuardsChanged: (v) => setState(() => _guards = v), addressCtrl: _addressCtrl)),
          if (_step == 2) _StepThree(notesCtrl: _notesCtrl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_step > 0)
                OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Back'))
              else const SizedBox(),
              ElevatedButton(
                onPressed: () async {
                  if (_step == 0) {
                    if (_step1Key.currentState?.validate() ?? false) setState(() => _step++);
                  } else if (_step == 1) {
                    if (_step2Key.currentState?.validate() ?? false) setState(() => _step++);
                  } else {
                    await _submitQuote();
                  }
                },
                child: Text(_step == 2 ? 'Submit Request' : 'Next Step'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _StepOne() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Contact Information', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Tell us who you are and how to reach you.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 24),
      TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _companyCtrl, decoration: const InputDecoration(labelText: 'Company / Organisation', prefixIcon: Icon(Icons.business)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Company name is required' : null),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Email is required';
          final emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
          if (!emailRe.hasMatch(v.trim())) return 'Enter a valid email address';
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Phone / WhatsApp', prefixIcon: Icon(Icons.phone)),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Phone number is required';
          if (v.replaceAll(RegExp(r'\D'), '').length < 8) return 'Enter a valid phone number';
          return null;
        },
      ),
    ],
  );

  Widget _StepTwo({required String selectedService, required int guards, required ValueChanged<String> onServiceChanged, required ValueChanged<int> onGuardsChanged, required TextEditingController addressCtrl}) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Service Requirements', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Tell us what you need and where.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 24),
      DropdownButtonFormField<String>(
        value: selectedService,
        dropdownColor: AppColors.surface,
        decoration: const InputDecoration(labelText: 'Service Type', prefixIcon: Icon(Icons.security)),
        items: _services.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
        onChanged: (v) => onServiceChanged(v ?? selectedService),
      ),
      const SizedBox(height: 16),
      Row(children: [
        const Expanded(child: Text('Number of guards required:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Row(children: [
          IconButton(icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary), onPressed: () => onGuardsChanged(guards > 1 ? guards - 1 : 1)),
          Text('$guards', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.primary), onPressed: () => onGuardsChanged(guards + 1)),
        ]),
      ]),
      const SizedBox(height: 16),
      TextFormField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Site Address', hintText: 'Property address in Lusaka / Zambia', prefixIcon: Icon(Icons.location_on), alignLabelWithHint: true), validator: (v) => (v == null || v.trim().isEmpty) ? 'Site address is required' : null),
    ]);

  Widget _StepThree({required TextEditingController notesCtrl}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Additional Details', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Any special requirements or context we should know.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
      const SizedBox(height: 24),
      TextFormField(controller: notesCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Additional Notes (optional)', hintText: 'Describe any specific requirements, risk concerns, or deadlines...', alignLabelWithHint: true)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 16),
          SizedBox(width: 10),
          Expanded(child: Text('A Magnum Security consultant will contact you within 24 hours with a tailored proposal and pricing in ZMW.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5))),
        ]),
      ),
    ],
  );

  Widget _SuccessView() => Container(
    padding: const EdgeInsets.all(48),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder, width: 0.5)),
    child: Column(children: const [
      Icon(Icons.verified, color: AppColors.primary, size: 64),
      SizedBox(height: 20),
      Text('Quote Request Submitted!', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
      SizedBox(height: 12),
      Text('Thank you. A Magnum Security consultant will reach out within 24 hours with a personalised quote in ZMW.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6), textAlign: TextAlign.center),
      SizedBox(height: 8),
      Text('For urgent enquiries: 0800 123 456', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(3, (i) {
      final labels = ['Contact', 'Service', 'Details'];
      final done = i < currentStep;
      final active = i == currentStep;
      return Expanded(child: Row(children: [
        if (i > 0) Expanded(child: Container(height: 1, color: done ? AppColors.primary : AppColors.divider)),
        Column(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || active ? AppColors.primary : AppColors.surface,
              border: Border.all(color: done || active ? AppColors.primary : AppColors.cardBorder),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.black, size: 16)
                : Center(child: Text('${i + 1}', style: TextStyle(color: active ? Colors.black : AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 4),
          Text(labels[i], style: TextStyle(color: active ? AppColors.primary : AppColors.textMuted, fontSize: 11)),
        ]),
        if (i < 2) Expanded(child: Container(height: 1, color: done ? AppColors.primary : AppColors.divider)),
      ]));
    }),
  );
}

class _QuoteHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.bgDark, AppColors.bgMid])),
    child: Column(children: const [
      Text('FREE QUOTE', style: TextStyle(color: AppColors.primary, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.w700)),
      SizedBox(height: 12),
      Text('Request a Security Proposal', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      SizedBox(height: 12),
      Text('No obligation. Customised pricing in ZMW. Response within 24 hours.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15), textAlign: TextAlign.center),
    ]),
  );
}
