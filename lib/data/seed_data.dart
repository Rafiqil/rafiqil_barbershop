import 'dart:math';
import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../models/transaction.dart';
import '../models/schedule.dart';

/// Menyediakan data demo realistis yang di-seed saat aplikasi pertama dibuka,
/// sehingga aplikasi langsung terasa "hidup".
class SeedData {
  static const List<String> barbers = [
    'Rafiqil',
    'Dimas',
    'Bayu',
    'Reza',
  ];

  static List<BarberService> services() => [
        BarberService(
          id: 'svc-1',
          name: 'Potong Rambut Pria',
          description: 'Cukur rapi sesuai gaya pilihan, termasuk keramas.',
          price: 35000,
          durationMinutes: 30,
          icon: Icons.content_cut,
        ),
        BarberService(
          id: 'svc-2',
          name: 'Cukur + Cuci + Pijat',
          description: 'Paket lengkap potong rambut, keramas, dan pijat kepala.',
          price: 55000,
          durationMinutes: 45,
          icon: Icons.spa,
        ),
        BarberService(
          id: 'svc-3',
          name: 'Cukur Jenggot',
          description: 'Merapikan & membentuk jenggot dengan handuk hangat.',
          price: 25000,
          durationMinutes: 20,
          icon: Icons.face_retouching_natural,
        ),
        BarberService(
          id: 'svc-4',
          name: 'Hair Coloring',
          description: 'Pewarnaan rambut profesional, banyak pilihan warna.',
          price: 120000,
          durationMinutes: 90,
          icon: Icons.brush,
        ),
        BarberService(
          id: 'svc-5',
          name: 'Kids Haircut',
          description: 'Potong rambut khusus anak, sabar & ramah anak.',
          price: 30000,
          durationMinutes: 25,
          icon: Icons.child_care,
        ),
        BarberService(
          id: 'svc-6',
          name: 'Hair Spa & Treatment',
          description: 'Perawatan rambut & kulit kepala agar sehat berkilau.',
          price: 90000,
          durationMinutes: 60,
          icon: Icons.water_drop,
        ),
        BarberService(
          id: 'svc-7',
          name: 'Pomade Styling',
          description: 'Penataan rambut dengan pomade premium.',
          price: 20000,
          durationMinutes: 15,
          active: false,
          icon: Icons.auto_awesome,
        ),
      ];

  static List<Customer> customers() {
    final now = DateTime.now();
    final names = [
      ['Andi Pratama', '081234567801', 'andi.pratama@gmail.com'],
      ['Budi Santoso', '081234567802', 'budi.santoso@gmail.com'],
      ['Citra Lestari', '081234567803', 'citra.lestari@gmail.com'],
      ['Dewa Saputra', '081234567804', 'dewa.saputra@gmail.com'],
      ['Eko Wijaya', '081234567805', 'eko.wijaya@gmail.com'],
      ['Fajar Nugroho', '081234567806', 'fajar.nugroho@gmail.com'],
      ['Gilang Ramadhan', '081234567807', 'gilang.r@gmail.com'],
      ['Hadi Kurniawan', '081234567808', 'hadi.kurniawan@gmail.com'],
      ['Indra Maulana', '081234567809', 'indra.maulana@gmail.com'],
      ['Joko Susilo', '081234567810', 'joko.susilo@gmail.com'],
      ['Krisna Adi', '081234567811', null],
      ['Lukman Hakim', '081234567812', 'lukman.hakim@gmail.com'],
    ];
    final rnd = Random(7);
    return List.generate(names.length, (i) {
      final visits = rnd.nextInt(18) + 1;
      return Customer(
        id: 'cust-${i + 1}',
        name: names[i][0]!,
        phone: names[i][1]!,
        email: names[i][2],
        visits: visits,
        joinedAt: now.subtract(Duration(days: rnd.nextInt(400) + 10)),
        lastVisit: now.subtract(Duration(days: rnd.nextInt(40))),
        note: i % 4 == 0 ? 'Langganan, suka model fade.' : null,
      );
    });
  }

  static List<BarberTransaction> transactions(
    List<Customer> custs,
    List<BarberService> svcs,
  ) {
    final rnd = Random(11);
    final now = DateTime.now();
    final list = <BarberTransaction>[];
    const methods = PaymentMethod.values;

    for (int i = 0; i < 24; i++) {
      final cust = custs[rnd.nextInt(custs.length)];
      final chosen = <BarberService>{};
      final count = rnd.nextInt(2) + 1;
      while (chosen.length < count) {
        chosen.add(svcs[rnd.nextInt(svcs.length)]);
      }
      final total = chosen.fold<int>(0, (s, e) => s + e.price);
      final daysAgo = rnd.nextInt(30);
      final created = now.subtract(
        Duration(days: daysAgo, hours: rnd.nextInt(9), minutes: rnd.nextInt(60)),
      );
      TransactionStatus status = TransactionStatus.paid;
      if (i % 11 == 0) status = TransactionStatus.pending;
      if (i % 17 == 0) status = TransactionStatus.cancelled;

      list.add(BarberTransaction(
        id: 'trx-${i + 1}',
        invoiceNo: 'INV-${created.year}${created.month.toString().padLeft(2, '0')}-${(1000 + i)}',
        customerId: cust.id,
        customerName: cust.name,
        barberName: barbers[rnd.nextInt(barbers.length)],
        serviceIds: chosen.map((e) => e.id).toList(),
        serviceNames: chosen.map((e) => e.name).toList(),
        total: total,
        method: methods[rnd.nextInt(methods.length)],
        status: status,
        createdAt: created,
      ));
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static List<Schedule> schedules(
    List<Customer> custs,
    List<BarberService> svcs,
  ) {
    final rnd = Random(5);
    final now = DateTime.now();
    final list = <Schedule>[];
    final activeSvcs = svcs.where((s) => s.active).toList();

    // Beberapa jadwal hari ini & mendatang
    for (int i = 0; i < 14; i++) {
      final cust = custs[rnd.nextInt(custs.length)];
      final svc = activeSvcs[rnd.nextInt(activeSvcs.length)];
      final dayOffset = rnd.nextInt(7); // 0..6 hari ke depan
      final hour = 9 + rnd.nextInt(9); // 09:00 - 17:00
      final start = DateTime(now.year, now.month, now.day, hour, rnd.nextBool() ? 0 : 30)
          .add(Duration(days: dayOffset));

      ScheduleStatus status = ScheduleStatus.upcoming;
      if (start.isBefore(now)) {
        status = start.add(Duration(minutes: svc.durationMinutes)).isAfter(now)
            ? ScheduleStatus.ongoing
            : ScheduleStatus.done;
      }
      if (i % 9 == 0) status = ScheduleStatus.cancelled;

      list.add(Schedule(
        id: 'sch-${i + 1}',
        customerId: cust.id,
        customerName: cust.name,
        serviceId: svc.id,
        serviceName: svc.name,
        barberName: barbers[rnd.nextInt(barbers.length)],
        startTime: start,
        durationMinutes: svc.durationMinutes,
        status: status,
        note: i % 5 == 0 ? 'Minta barber Rafiqil.' : null,
      ));
    }
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }
}
