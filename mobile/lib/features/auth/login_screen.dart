import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      showMessage(context, auth.error ?? 'Gagal masuk.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: AppLogo(size: 96)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text('Masuk Akun Quizin',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
                  ),
                  const SizedBox(height: 24),
                  const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email@gmail.com'),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Email wajib diisi';
                      if (!t.contains('@') || !t.contains('.')) return 'Format email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _password,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      hintText: 'Sandi',
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) => (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Masuk Akun', loading: loading, onPressed: _submit),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Belum Punya Akun',
                    onPressed: loading ? null : () => Navigator.of(context).pushNamed(AppRoutes.register),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Akun contoh (data dummy): demo@quizin.test / password123',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
