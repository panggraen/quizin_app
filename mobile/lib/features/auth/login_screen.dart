import 'package:flutter/foundation.dart'; // BARU: untuk kDebugMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/secondary_button.dart';
 
class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});
 
  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}
 
class _LoginScreenV2State extends State<LoginScreenV2> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
 
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode(); 
  bool _hide = true;
 
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordFocus.dispose(); 
    super.dispose();
  }
 
  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
 
    if (auth.loading) return;
 
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
 
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      TextInput.finishAutofillContext();
      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      TextInput.finishAutofillContext(shouldSave: false);
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
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: AppLogo(size: 96)),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Masuk Akun Quizin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Email',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _email,
                      readOnly: loading, 
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next, 
                      autofillHints: const [AutofillHints.email], 
                      onFieldSubmitted: (_) =>
                          _passwordFocus.requestFocus(), 
                      decoration:
                          const InputDecoration(hintText: 'Email@gmail.com'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Email wajib diisi';
                        if (!_emailRegex.hasMatch(t)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Kata Sandi',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _password,
                      focusNode: _passwordFocus, 
                      readOnly: loading, 
                      obscureText: _hide,
                      textInputAction: TextInputAction.done, 
                      autofillHints: const [AutofillHints.password], 
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Sandi',
                        suffixIcon: IconButton(
                          tooltip: _hide
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          icon: Icon(_hide
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
      
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'Kata sandi wajib diisi' : null,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Masuk Akun',
                      loading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      label: 'Belum Punya Akun',
                      onPressed: loading
                          ? null
                          : () => Navigator.of(context)
                              .pushNamed(AppRoutes.register),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Akun contoh (data dummy): demo@quizin.test / password123',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 