import 'package:flutter/material.dart';

/// A high-priority district issue shown in the admin priority inbox
class PriorityIssue {
  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final Color tagColor;
  final IconData icon;
  final int upvotes;

  const PriorityIssue({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.upvotes,
  });

  // TODO: Add fromFirestore factory when Firestore is connected
  // factory PriorityIssue.fromFirestore(DocumentSnapshot doc) { ... }
}
