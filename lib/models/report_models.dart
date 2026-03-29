import 'package:flutter/material.dart';

/// Status values a report can have as it moves through the pipeline.
enum ReportStatus { submitted, received, assigned, fieldVisit, resolved }

/// A single report card shown in the citizen feed or My Reports list.
class ReportItem {
  final String id;
  final String title;
  final ReportStatus status;
  final String category;
  final IconData categoryIcon;
  final String? location;
  final String? date;
  final String? description;

  const ReportItem({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.categoryIcon,
    this.location,
    this.date,
    this.description,
  });
}

/// Expanded detail view data built from a [ReportItem].
class ReportDetailData {
  final String id;
  final String title;
  final ReportStatus status;
  final String category;
  final IconData categoryIcon;
  final String location;
  final String date;
  final String? description;

  const ReportDetailData({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    required this.categoryIcon,
    required this.location,
    required this.date,
    this.description,
  });

  factory ReportDetailData.fromReportItem(
    ReportItem item, {
    required String location,
    required String date,
  }) {
    return ReportDetailData(
      id: item.id,
      title: item.title,
      status: item.status,
      category: item.category,
      categoryIcon: item.categoryIcon,
      location: location,
      date: date,
      description: item.description,
    );
  }
}

/// Monthly statistics used in the admin dashboard chart.
class MonthData {
  final String month;
  final int resolved;
  final int received;

  const MonthData({
    required this.month,
    required this.resolved,
    required this.received,
  });
}

/// A single message in the citizen–officer chat thread.
class ChatMessage {
  final String text;
  final bool isOfficer;
  final bool isCitizen;
  final String? imageUrl;
  final DateTime? createdAt;

  const ChatMessage({
    required this.text,
    this.isOfficer = false,
    this.isCitizen = false,
    this.imageUrl,
    this.createdAt,
  });
}

/// A stat tile shown at the top of the admin dashboard.
class AdminStat {
  final String label;
  final String value;
  final String trend;
  final bool? trendUp;
  final Color color;

  const AdminStat({
    required this.label,
    required this.value,
    required this.trend,
    this.trendUp,
    required this.color,
  });
}

/// A high-priority issue shown in the priority list widget.
class PriorityIssue {
  final String id;
  final String title;
  final String district;
  final String priority;
  final ReportStatus status;

  const PriorityIssue({
    required this.id,
    required this.title,
    required this.district,
    required this.priority,
    required this.status,
  });
}

/// An issue record used in the admin issue management screen.
class AdminIssue {
  final String id;
  final String title;
  final ReportStatus status;
  final String? category;
  final String? district;

  const AdminIssue({
    required this.id,
    required this.title,
    this.status = ReportStatus.submitted,
    this.category,
    this.district,
  });
}
