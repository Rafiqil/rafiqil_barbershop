import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl =
      TextEditingController(text: AuthProvider.demoEmail);
  final _passCtrl = TextEditingController(text: AuthProvider.demoPassword);
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text, _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Gagal masuk'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final wide = MediaQuery.of(context).size.width >= 900;

    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!wide) ...[
                  const _Brand(),
                  const SizedBox(height: 32),
                ],
                const Text('Selamat datang kembali 👋',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk mengelola Rafiqil Barbershop Anda.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                const Text('Email',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'admin@rafiqil.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                ),
                const SizedBox(height: 18),
                const Text('Kata Sandi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 4)
                      ? 'Minimal 4 karakter'
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.primaryDark),
                    child: auth.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.primaryDark),
                          )
                        : const Text('Masuk'),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.infoSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline,
                          size: 18, color: AppColors.info),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Akun demo:\nadmin@rafiqil.com  •  rafiqil123',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.info,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!wide) {
      return Scaffold(body: form);
    }

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 5, child: _BrandPanel()),
          Expanded(flex: 4, child: form),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentSoft]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.content_cut,
              color: AppColors.primaryDark, size: 26),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rafiqil Barbershop',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Sistem Manajemen',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: _circle(220, AppColors.accent.withOpacity(.10)),
          ),
          Positioned(
            left: -50,
            bottom: -30,
            child: _circle(180, AppColors.accent.withOpacity(.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentSoft]),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.content_cut,
                      color: AppColors.primaryDark, size: 34),
                ),
                const SizedBox(height: 28),
                const Text('Rafiqil Barbershop',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.1)),
                const SizedBox(height: 16),
                const Text(
                  'Kelola pelanggan, layanan, transaksi, dan jadwal\nbarbershop Anda dalam satu dashboard yang rapi.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 36),
                ...const [
                  _Feature(Icons.people_alt_outlined, 'Manajemen pelanggan & riwayat kunjungan'),
                  _Feature(Icons.receipt_long_outlined, 'Pencatatan transaksi & laporan omset'),
                  _Feature(Icons.calendar_month_outlined, 'Penjadwalan reservasi pelanggan'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Feature(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentSoft, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
