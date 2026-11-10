import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    } else {
      showMessage(context, auth.error ?? 'Pendaftaran gagal.');
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

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
                  const Center(child: AppLogo(size: 88)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text('Buat Akun Quizin',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accent(context))),
                  ),
                  _label('Email'),
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
                  _label('Nomor Telepon'),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+62...'),
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.isEmpty) return 'Nomor telepon wajib diisi';
                      if (digits.length < 9) return 'Nomor telepon terlalu pendek';
                      return null;
                    },
                  ),
                  _label('Nama Lengkap'),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: 'Nama Lengkap'),
                    validator: (v) => (v ?? '').trim().length < 2 ? 'Nama minimal 2 karakter' : null,
                  ),
                  _label('Kata Sandi'),
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
                    // Aturan sandi final belum diputuskan tim; sementara minimal 8 karakter.
                    validator: (v) => (v ?? '').length < 8 ? 'Kata sandi minimal 8 karakter' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Daftar Akun', loading: loading, onPressed: _submit),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Sudah Punya Akun',
                    onPressed: loading ? null : () => Navigator.of(context).pop(),
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
