import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/seed_data.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../models/transaction.dart';
import '../models/schedule.dart';

/// Repository in-memory yang berperan sebagai "backend palsu".
/// Mensimulasikan latensi jaringan, status loading, dan optimistic update.
class DataProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final _rnd = Random();

  bool _seeded = false;
  bool _loading = true;

  List<Customer> _customers = [];
  List<BarberService> _services = [];
  List<BarberTransaction> _transactions = [];
  List<Schedule> _schedules = [];

  bool get loading => _loading;
  bool get seeded => _seeded;

  List<Customer> get customers => List.unmodifiable(_customers);
  List<BarberService> get services => List.unmodifiable(_services);
  List<BarberTransaction> get transactions => List.unmodifiable(_transactions);
  List<Schedule> get schedules => List.unmodifiable(_schedules);

  List<BarberService> get activeServices =>
      _services.where((s) => s.active).toList();

  /// Seed data demo pada saat pertama kali aplikasi dibuka.
  Future<void> bootstrap() async {
    if (_seeded) return;
    _loading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1100));

    _services = SeedData.services();
    _customers = SeedData.customers();
    _transactions = SeedData.transactions(_customers, _services);
    _schedules = SeedData.schedules(_customers, _services);

    _seeded = true;
    _loading = false;
    notifyListeners();
  }

  Future<void> _fakeNetwork() =>
      Future.delayed(Duration(milliseconds: 350 + _rnd.nextInt(450)));

  // ----------------------------- DASHBOARD STATS -----------------------------

  int get totalOmsetBulanIni {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.status == TransactionStatus.paid &&
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month)
        .fold(0, (s, t) => s + t.total);
  }

  int get totalOmsetHariIni {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.status == TransactionStatus.paid &&
            t.createdAt.year == now.year &&
            t.createdAt.month == now.month &&
            t.createdAt.day == now.day)
        .fold(0, (s, t) => s + t.total);
  }

  int get jadwalHariIni {
    final now = DateTime.now();
    return _schedules
        .where((s) =>
            s.startTime.year == now.year &&
            s.startTime.month == now.month &&
            s.startTime.day == now.day &&
            s.status != ScheduleStatus.cancelled)
        .length;
  }

  int get transaksiBulanIni {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.createdAt.year == now.year && t.createdAt.month == now.month)
        .length;
  }

  /// Omset 7 hari terakhir (untuk grafik).
  List<MapEntry<DateTime, int>> get omset7Hari {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final total = _transactions
          .where((t) =>
              t.status == TransactionStatus.paid &&
              t.createdAt.year == day.year &&
              t.createdAt.month == day.month &&
              t.createdAt.day == day.day)
          .fold(0, (s, t) => s + t.total);
      return MapEntry(day, total);
    });
  }

  /// Layanan terlaris berdasarkan jumlah pemakaian.
  List<MapEntry<String, int>> get layananTerlaris {
    final map = <String, int>{};
    for (final t in _transactions) {
      if (t.status == TransactionStatus.cancelled) continue;
      for (final name in t.serviceNames) {
        map[name] = (map[name] ?? 0) + 1;
      }
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  List<Schedule> get jadwalMendatang {
    final now = DateTime.now();
    final list = _schedules
        .where((s) =>
            s.status != ScheduleStatus.cancelled &&
            s.status != ScheduleStatus.done &&
            s.startTime.isAfter(now.subtract(const Duration(hours: 1))))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list.take(5).toList();
  }

  // ----------------------------- CUSTOMERS CRUD -----------------------------

  Future<void> addCustomer(Customer c) async {
    // Optimistic insert.
    _customers = [c, ..._customers];
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> updateCustomer(Customer updated) async {
    final idx = _customers.indexWhere((c) => c.id == updated.id);
    if (idx == -1) return;
    final old = _customers[idx];
    _customers[idx] = updated; // optimistic
    notifyListeners();
    try {
      await _fakeNetwork();
    } catch (_) {
      _customers[idx] = old; // rollback
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String id) async {
    final removed = _customers.where((c) => c.id == id).toList();
    _customers = _customers.where((c) => c.id != id).toList(); // optimistic
    notifyListeners();
    try {
      await _fakeNetwork();
    } catch (_) {
      _customers = [..._customers, ...removed];
      notifyListeners();
    }
  }

  Customer? customerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ----------------------------- SERVICES CRUD -----------------------------

  Future<void> addService(BarberService s) async {
    _services = [s, ..._services];
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> updateService(BarberService updated) async {
    final idx = _services.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;
    _services[idx] = updated;
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> deleteService(String id) async {
    final removed = _services.where((s) => s.id == id).toList();
    _services = _services.where((s) => s.id != id).toList();
    notifyListeners();
    try {
      await _fakeNetwork();
    } catch (_) {
      _services = [..._services, ...removed];
      notifyListeners();
    }
  }

  Future<void> toggleServiceActive(String id) async {
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _services[idx] = _services[idx].copyWith(active: !_services[idx].active);
    notifyListeners();
    await _fakeNetwork();
  }

  // ----------------------------- TRANSACTIONS CRUD -----------------------------

  Future<void> addTransaction(BarberTransaction t) async {
    _transactions = [t, ..._transactions];
    // perbarui kunjungan pelanggan
    final idx = _customers.indexWhere((c) => c.id == t.customerId);
    if (idx != -1) {
      _customers[idx] = _customers[idx].copyWith(
        visits: _customers[idx].visits + 1,
        lastVisit: t.createdAt,
      );
    }
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> updateTransaction(BarberTransaction updated) async {
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    _transactions[idx] = updated;
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> deleteTransaction(String id) async {
    final removed = _transactions.where((t) => t.id == id).toList();
    _transactions = _transactions.where((t) => t.id != id).toList();
    notifyListeners();
    try {
      await _fakeNetwork();
    } catch (_) {
      _transactions = [...removed, ..._transactions];
      notifyListeners();
    }
  }

  Future<void> setTransactionStatus(
      String id, TransactionStatus status) async {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _transactions[idx] = _transactions[idx].copyWith(status: status);
    notifyListeners();
    await _fakeNetwork();
  }

  String nextInvoiceNo() {
    final now = DateTime.now();
    final seq = _transactions.length + 1001;
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}-$seq';
  }

  // ----------------------------- SCHEDULES CRUD -----------------------------

  Future<void> addSchedule(Schedule s) async {
    _schedules = [..._schedules, s]..sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> updateSchedule(Schedule updated) async {
    final idx = _schedules.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;
    _schedules[idx] = updated;
    _schedules.sort((a, b) => a.startTime.compareTo(b.startTime));
    notifyListeners();
    await _fakeNetwork();
  }

  Future<void> deleteSchedule(String id) async {
    final removed = _schedules.where((s) => s.id == id).toList();
    _schedules = _schedules.where((s) => s.id != id).toList();
    notifyListeners();
    try {
      await _fakeNetwork();
    } catch (_) {
      _schedules = [..._schedules, ...removed]
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      notifyListeners();
    }
  }

  Future<void> setScheduleStatus(String id, ScheduleStatus status) async {
    final idx = _schedules.indexWhere((s) => s.id == id);
    if (idx == -1) return;
    _schedules[idx] = _schedules[idx].copyWith(status: status);
    notifyListeners();
    await _fakeNetwork();
  }

  String genId(String prefix) => '$prefix-${_uuid.v4().substring(0, 8)}';
}
