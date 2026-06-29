import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:device_frame/device_frame.dart';

import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/app_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal Bahasa Indonesia.
  await initializeDateFormatting('id_ID', null);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeviceFrame(
        device: Devices.ios.iPhone13,
        isFrameVisible: true,
        screen: const RafiqilApp(),
      ),
    ),
  );
}

class RafiqilApp extends StatelessWidget {
  const RafiqilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'Rafiqil Barbershop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Menentukan apakah menampilkan layar login atau dashboard,
/// dan men-seed data demo saat pertama kali login.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _bootstrapped = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      _bootstrapped = false;
      return const LoginScreen();
    }

    // Seed data demo sekali setelah login.
    if (!_bootstrapped) {
      _bootstrapped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DataProvider>().bootstrap();
      });
    }

    return const AppShell();
  }
}
