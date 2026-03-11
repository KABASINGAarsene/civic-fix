import 'package:flutter/material.dart';

/// KPI stat card model for the admin dashboard grid
class AdminStat {
  final String label;
  final String value;
  final String trend;
  final bool? trendUp; // true = good, false = bad, null = neutral
  final IconData icon;
  final Color color;

  const AdminStat({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.icon,
    required this.color,
  });

  // TODO: Add fromFirestore factory when Firestore is connected
  // factory AdminStat.fromFirestore(DocumentSnapshot doc) { ... }
}
