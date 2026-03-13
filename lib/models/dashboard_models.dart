import 'package:flutter/material.dart';

// --- Shared Enums ---

enum ReportStatus { submitted, inReview, inProgress, resolved, reported }

// --- Citizen Domain Models ---

// Domain model for a citizen-reported issue (used in the feed)
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

// Full detail model for a single report - used in ReportDetailScreen
class ReportDetailData {
  final String trackingId;
  final String title;
  final String description;
  final String category;
  final IconData categoryIcon;
  final ReportStatus status;
  final String location;
  final String submittedDate;
  final String lastUpdate;
  final int likes;
  final int comments;
  final String? assignedTo;
  final String? photoUrl;

  const ReportDetailData({
    required this.trackingId,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryIcon,
    required this.status,
    required this.location,
    required this.submittedDate,
    required this.lastUpdate,
    required this.likes,
    required this.comments,
    this.assignedTo,
    this.photoUrl,
  });

  // Convenience factory to build a ReportDetailData from a ReportItem
  // (for when you tap a card on the home screen)
  factory ReportDetailData.fromReportItem(
    ReportItem item, {
    required String location,
    required String submittedDate,
    required String lastUpdate,
    String? assignedTo,
    String? photoUrl,
  }) {
    return ReportDetailData(
      trackingId: item.id,
      title: item.title,
      description: item.description,
      category: item.category,
      categoryIcon: item.icon,
      status: item.status,
      location: location,
      submittedDate: submittedDate,
      lastUpdate: lastUpdate,
      likes: item.likes,
      comments: item.comments,
      assignedTo: assignedTo,
      photoUrl: photoUrl,
    );
  }
}

// --- Admin Domain Models ---

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
}

// A high-priority district issue shown in the admin priority inbox
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
}

// Monthly performance data point for the admin bar chart
class MonthData {
  final String month;
  final int resolved;
  final int received;

  const MonthData(this.month, this.resolved, this.received);
}
