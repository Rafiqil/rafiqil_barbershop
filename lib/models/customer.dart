/// Model Pelanggan.
class Customer {
  final String id;
  String name;
  String phone;
  String? email;
  String? note;
  int visits;
  DateTime joinedAt;
  DateTime? lastVisit;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.note,
    this.visits = 0,
    required this.joinedAt,
    this.lastVisit,
  });

  Customer copyWith({
    String? name,
    String? phone,
    String? email,
    String? note,
    int? visits,
    DateTime? lastVisit,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      note: note ?? this.note,
      visits: visits ?? this.visits,
      joinedAt: joinedAt,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}
