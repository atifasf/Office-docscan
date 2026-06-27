import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  bool _isRegister    = false;
  bool _obscure       = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(40),

              // Logo
              Center(
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.scannerGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 40),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              ),
              const Gap(24),
              Center(
                child: Text(
                  'ScanVerse AI',
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 200.ms),
              ),
              Center(
                child: Text(
                  _isRegister ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ).animate().fadeIn(delay: 300.ms),
              ),
              const Gap(40),

              // Error
              if (auth.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.errorRed.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.errorRed, size: 16),
                    const Gap(8),
                    Expanded(child: Text(auth.error!, style: const TextStyle(color: AppTheme.errorRed, fontSize: 13))),
                  ]),
                ).animate().shake(),

              // Name (register only)
              if (_isRegister) ...[
                _buildField(controller: _nameCtrl, label: 'Full Name', icon: Icons.person_outline_rounded),
                const Gap(16),
              ],

              // Email
              _buildField(controller: _emailCtrl, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
              const Gap(16),

              // Password
              _buildField(
                controller: _passwordCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary, size: 20),
                ),
              ),
              const Gap(28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isRegister ? 'Create Account' : 'Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const Gap(20),

              // Toggle
              Center(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isRegister = !_isRegister;
                  }),
                  child: RichText(
                    text: TextSpan(
                      text: _isRegister ? 'Already have an account? ' : "Don't have an account? ",
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      children: [
                        TextSpan(
                          text: _isRegister ? 'Login' : 'Register',
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.surfaceCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue)),
      ),
    );
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final notifier = ref.read(authProvider.notifier);

    if (_isRegister) {
      final name = _nameCtrl.text.trim();
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }
      await notifier.register(name: name, email: email, password: password);
    } else {
      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }
      await notifier.login(email: email, password: password);
    }
  }
}
