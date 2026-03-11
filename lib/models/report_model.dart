import 'package:flutter/material.dart';

// Report status enum for district issue reports
enum ReportStatus { reported, inProgress, resolved }

// Domain model for a citizen-reported issue
class ReportItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String timeLocation;
  final ReportStatus status;
  final IconData icon;
  final int likes;
  final int comments;

  const ReportItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.timeLocation,
    required this.status,
    required this.icon,
    required this.likes,
    required this.comments,
  });
}
