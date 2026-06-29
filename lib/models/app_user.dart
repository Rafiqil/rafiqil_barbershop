/// Pengguna aplikasi (untuk autentikasi).
class AppUser {
  final String name;
  final String email;
  final String role;
  final String phone;

  const AppUser({
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
  });
}
