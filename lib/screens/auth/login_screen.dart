import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_nav_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _resetEmailCtrl = TextEditingController();
  bool _obscure     = true;
  bool _resetSent   = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: const CustomNavBar(showAuthButtons: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.shield, color: Colors.black, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text('Magnum Security', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const Text('Client Portal', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                        const SizedBox(width: 8),
                        Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                      ]),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: auth.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : ElevatedButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text('Sign In'),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
                      child: const Text('Back to Website', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: _showForgotPassword,
                      child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    _resetEmailCtrl.text = _emailCtrl.text;
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Reset Password', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Enter your email address and we\'ll send you a reset link.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        const SizedBox(height: 16),
        TextField(
          controller: _resetEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
        ),
        if (_resetSent)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(children: const [
              Icon(Icons.check_circle, color: AppColors.success, size: 16),
              SizedBox(width: 6),
              Expanded(child: Text('Reset link sent! Check your inbox.', style: TextStyle(color: AppColors.success, fontSize: 12))),
            ]),
          ),
      ]),
      actions: [
        TextButton(onPressed: () { Navigator.pop(context); setState(() => _resetSent = false); }, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final auth = context.read<AuthService>();
            final err = await auth.sendPasswordReset(_resetEmailCtrl.text.trim());
            if (!mounted) return;
            if (err == null) {
              setState(() => _resetSent = true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.error));
            }
          },
          child: const Text('Send Link'),
        ),
      ],
    ));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _error = null);
    final auth = context.read<AuthService>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (!mounted) return;
    if (ok) {
      final role = auth.currentUser?.role;
      final route = role == UserRole.admin ? AppRoutes.adminDashboard : role == UserRole.guard ? AppRoutes.guardDashboard : AppRoutes.clientDashboard;
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } else {
      setState(() => _error = 'Invalid credentials. Please try again.');
    }
  }
}
