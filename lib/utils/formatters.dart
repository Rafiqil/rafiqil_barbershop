import 'package:intl/intl.dart';

/// Helper format mata uang Rupiah dan tanggal Bahasa Indonesia.
class Formatters {
  static final NumberFormat _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _compact =
      NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String rupiah(num value) => _rupiah.format(value);

  static String rupiahCompact(num value) => _compact.format(value);

  static String tanggal(DateTime date) =>
      DateFormat('d MMM yyyy', 'id_ID').format(date);

  static String tanggalLengkap(DateTime date) =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

  static String jam(DateTime date) => DateFormat('HH:mm', 'id_ID').format(date);

  static String tanggalJam(DateTime date) =>
      DateFormat('d MMM yyyy • HH:mm', 'id_ID').format(date);

  static String hariSingkat(DateTime date) =>
      DateFormat('EEE', 'id_ID').format(date);

  static String inisial(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
