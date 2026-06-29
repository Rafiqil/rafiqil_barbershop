import 'package:flutter/material.dart';
import '../models/app_user.dart';

/// Mengelola status autentikasi (login/logout) dengan kredensial demo.
class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get loading => _loading;
  String? get error => _error;

  /// Kredensial demo (ditampilkan di layar login).
  static const String demoEmail = 'admin@rafiqil.com';
  static const String demoPassword = 'rafiqil123';

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    // Simulasi panggilan jaringan.
    await Future.delayed(const Duration(milliseconds: 900));

    final ok = email.trim().toLowerCase() == demoEmail &&
        password == demoPassword;

    if (ok) {
      _user = const AppUser(
        name: 'Rafiqil',
        email: demoEmail,
        role: 'Pemilik / Admin',
        phone: '+6282211283036',
      );
      _loading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email atau kata sandi salah. Coba kredensial demo di bawah.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
