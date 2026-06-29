/// Metode pembayaran.
enum PaymentMethod { cash, qris, transfer, card }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.transfer:
        return 'Transfer';
      case PaymentMethod.card:
        return 'Kartu';
    }
  }
}

/// Status transaksi.
enum TransactionStatus { paid, pending, cancelled }

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.paid:
        return 'Lunas';
      case TransactionStatus.pending:
        return 'Menunggu';
      case TransactionStatus.cancelled:
        return 'Batal';
    }
  }
}

/// Model Transaksi.
class BarberTransaction {
  final String id;
  String invoiceNo;
  String customerId;
  String customerName;
  String barberName;
  List<String> serviceIds;
  List<String> serviceNames;
  int total;
  PaymentMethod method;
  TransactionStatus status;
  DateTime createdAt;

  BarberTransaction({
    required this.id,
    required this.invoiceNo,
    required this.customerId,
    required this.customerName,
    required this.barberName,
    required this.serviceIds,
    required this.serviceNames,
    required this.total,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  BarberTransaction copyWith({
    String? customerId,
    String? customerName,
    String? barberName,
    List<String>? serviceIds,
    List<String>? serviceNames,
    int? total,
    PaymentMethod? method,
    TransactionStatus? status,
  }) {
    return BarberTransaction(
      id: id,
      invoiceNo: invoiceNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      barberName: barberName ?? this.barberName,
      serviceIds: serviceIds ?? this.serviceIds,
      serviceNames: serviceNames ?? this.serviceNames,
      total: total ?? this.total,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
