/// Status jadwal / reservasi.
enum ScheduleStatus { upcoming, ongoing, done, cancelled }

extension ScheduleStatusX on ScheduleStatus {
  String get label {
    switch (this) {
      case ScheduleStatus.upcoming:
        return 'Terjadwal';
      case ScheduleStatus.ongoing:
        return 'Berlangsung';
      case ScheduleStatus.done:
        return 'Selesai';
      case ScheduleStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

/// Model Jadwal / Reservasi.
class Schedule {
  final String id;
  String customerId;
  String customerName;
  String serviceId;
  String serviceName;
  String barberName;
  DateTime startTime;
  int durationMinutes;
  ScheduleStatus status;
  String? note;

  Schedule({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceId,
    required this.serviceName,
    required this.barberName,
    required this.startTime,
    required this.durationMinutes,
    this.status = ScheduleStatus.upcoming,
    this.note,
  });

  DateTime get endTime => startTime.add(Duration(minutes: durationMinutes));

  Schedule copyWith({
    String? customerId,
    String? customerName,
    String? serviceId,
    String? serviceName,
    String? barberName,
    DateTime? startTime,
    int? durationMinutes,
    ScheduleStatus? status,
    String? note,
  }) {
    return Schedule(
      id: id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      barberName: barberName ?? this.barberName,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
