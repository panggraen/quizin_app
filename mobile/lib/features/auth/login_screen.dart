import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quizin_app/core/routes/app_routes.dart';
import 'package:quizin_app/core/theme/app_colors.dart';
import 'package:quizin_app/core/utils/helpers.dart';
import 'package:quizin_app/providers/auth_provider.dart';
import 'package:quizin_app/widgets/app_logo.dart';
import 'package:quizin_app/widgets/auth_shell.dart';
import 'package:quizin_app/widgets/primary_button.dart';
import 'package:quizin_app/widgets/secondary_button.dart';

class LoginScreenV2 extends StatefulWidget {
  const LoginScreenV2({super.key});

  @override
  State<LoginScreenV2> createState() => _LoginScreenV2State();
}

class _LoginScreenV2State extends State<LoginScreenV2> {
  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    if (auth.loading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      TextInput.finishAutofillContext();

      Navigator.of(context).pushReplacementNamed(AppRoutes.main);
    } else {
      TextInput.finishAutofillContext(shouldSave: false);

      showMessage(
        context,
        auth.error ?? 'Gagal masuk.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return AuthShell(
      maxWidth: 440,
      builder: (context, layout) {
        return AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: AppLogo(size: layout.logoSize)),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Masuk Akun Quizin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent(context),
                    ),
                  ),
                ),

                SizedBox(height: layout.isShort ? 16 : 28),

                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _emailController,
                  readOnly: loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    hintText: 'Email@gmail.com',
                  ),
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (email.isEmpty) return 'Email wajib diisi';
                    if (!_emailRegex.hasMatch(email)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                const Text(
                  'Kata Sandi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  readOnly: loading,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Sandi',
                    suffixIcon: IconButton(
                      tooltip: _hidePassword
                          ? 'Tampilkan kata sandi'
                          : 'Sembunyikan kata sandi',
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              setState(() => _hidePassword = !_hidePassword);
                            },
                    ),
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    return null;
                  },
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
                      : () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                ),

                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Akun contoh (data dummy): '
                      'demo@quizin.test / password123',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}