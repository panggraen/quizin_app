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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    if (auth.loading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      TextInput.finishAutofillContext();

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.main,
        (route) => false,
      );
    } else {
      TextInput.finishAutofillContext(shouldSave: false);

      showMessage(
        context,
        auth.error ?? 'Pendaftaran gagal.',
      );
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool hidden,
    required VoidCallback onToggle,
    required String hintText,
    required String autofillHint,
    required String? Function(String?) validator,
    required bool loading,
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      readOnly: loading,
      obscureText: hidden,
      textInputAction: textInputAction,
      autofillHints: [autofillHint],
      onFieldSubmitted: (_) => onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          tooltip:
              hidden ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
          icon: Icon(
            hidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: loading ? null : onToggle,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return AuthShell(
      maxWidth: 480,
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
                    'Buat Akun Quizin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent(context),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Lengkapi data untuk membuat akun baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),

                // NAMA LENGKAP
                _label('Nama Lengkap'),
                TextFormField(
                  controller: _nameController,
                  readOnly: loading,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                  ),
                  validator: (value) {
                    final name = (value ?? '').trim();
                    if (name.isEmpty) return 'Nama lengkap wajib diisi';
                    if (name.length < 2) return 'Nama minimal 2 karakter';
                    return null;
                  },
                ),

                // EMAIL
                _label('Email'),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  readOnly: loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
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

                // NOMOR TELEPON
                _label('Nomor Telepon'),
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  readOnly: loading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  decoration: const InputDecoration(hintText: '62...'),
                  validator: (value) {
                    final digits =
                        (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');

                    if (digits.isEmpty) return 'Nomor telepon wajib diisi';

                    if (digits.length < 9 || digits.length > 15) {
                      return 'Panjang nomor telepon tidak valid';
                    }

                    if (RegExp(r'^0+$').hasMatch(digits)) {
                      return 'Nomor telepon tidak valid';
                    }

                    return null;
                  },
                ),

                // PASSWORD
                _label('Kata Sandi'),
                _buildPasswordField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hidden: _hidePassword,
                  loading: loading,
                  hintText: 'Minimal 8 karakter',
                  autofillHint: AutofillHints.newPassword,
                  onToggle: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    if (value!.length < 8) {
                      return 'Kata sandi minimal 8 karakter';
                    }
                    return null;
                  },
                  onSubmitted: () => _confirmPasswordFocusNode.requestFocus(),
                ),

                // KONFIRMASI PASSWORD
                _label('Konfirmasi Kata Sandi'),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  hidden: _hideConfirmPassword,
                  loading: loading,
                  hintText: 'Ulangi kata sandi',
                  autofillHint: AutofillHints.newPassword,
                  textInputAction: TextInputAction.done,
                  onToggle: () {
                    setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                    );
                  },
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (value != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                  onSubmitted: _submit,
                ),

                SizedBox(height: layout.isShort ? 20 : 28),

                PrimaryButton(
                  label: 'Daftar Akun',
                  loading: loading,
                  onPressed: _submit,
                ),

                const SizedBox(height: 10),

                SecondaryButton(
                  label: 'Sudah Punya Akun',
                  onPressed: loading
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}