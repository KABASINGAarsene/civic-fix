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
  final String address;
  final String priorityLabel;
  final bool isAnonymous;
  final bool hasAudioDescription;
  final String? audioPath;
  final List<String> attachedMedia;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.address = '',
    this.priorityLabel = 'Low',
    this.isAnonymous = false,
    this.hasAudioDescription = false,
    this.audioPath,
    this.attachedMedia = const [],
    this.assignedTo,
    this.createdAt,
    this.updatedAt,
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

// --- Admin Issue model (Issues Management & Ticket Detail screens) ---

class AdminIssue {
  final String id;
  final String title;
  final String location;
  final String timeAgo;
  final String priorityLabel; // 'HIGH PRIORITY', 'MEDIUM PRIORITY', 'LOW PRIORITY'
  final Color priorityColor;
  final int priorityScore; // 0–100
  final String category;
  final String status; // 'submitted', 'inProgress', 'resolved'
  final String description;
  final String address;
  final List<String> attachedMedia; // File paths for images/videos
  final bool hasAudioDescription;
  final String? audioPath;
  final String citizenId; // UID of the citizen who submitted the report

  const AdminIssue({
    required this.id,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.priorityLabel,
    required this.priorityColor,
    required this.priorityScore,
    required this.category,
    required this.status,
    this.description = '',
    this.address = '',
    this.attachedMedia = const [],
    this.hasAudioDescription = false,
    this.audioPath,
    this.citizenId = '',
  });
}

// --- Chat Message model (Officer-Citizen chat screen) ---

class ChatMessage {
  final String id;
  final String text;
  final bool isOfficer; // true = officer bubble (left), false = citizen (right)
  final String time;
  final bool hasImage;
  final String? senderId;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isOfficer,
    required this.time,
    this.hasImage = false,
    this.senderId,
    this.createdAt,
  });
}
