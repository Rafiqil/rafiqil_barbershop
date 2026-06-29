import 'package:flutter/material.dart';

/// Model Layanan / Jasa barbershop.
class BarberService {
  final String id;
  String name;
  String description;
  int price; // dalam Rupiah
  int durationMinutes;
  bool active;
  IconData icon;

  BarberService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.active = true,
    this.icon = Icons.content_cut,
  });

  BarberService copyWith({
    String? name,
    String? description,
    int? price,
    int? durationMinutes,
    bool? active,
    IconData? icon,
  }) {
    return BarberService(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      active: active ?? this.active,
      icon: icon ?? this.icon,
    );
  }
}
