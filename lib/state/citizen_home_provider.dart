import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class CitizenHomeProvider extends ChangeNotifier {
  // UI State

  int _selectedNavIndex = 0;
  int _selectedFilterIndex = 0;

  int get selectedNavIndex => _selectedNavIndex;
  int get selectedFilterIndex => _selectedFilterIndex;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    // TODO: Re-fetch feed filtered by district/sector/cell when index changes
    notifyListeners();
  }

  // Feed Data State

  List<ReportItem> _feedItems = [];
  List<ReportItem> _myReportedItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportItem> get feedItems => _feedItems;
  List<ReportItem> get myReportedItems => _myReportedItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Call this from initState of the screen to load the feed.
  Future<void> loadFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with real Firestore fetch:
      //
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('reports')
      //     .orderBy('createdAt', descending: true)
      //     .limit(20)
      //     .get();
      //
      // _feedItems = snapshot.docs
      //     .map((doc) => ReportItem.fromFirestore(doc))
      //     .toList();

      // Temporary placeholder data — remove once Firestore is connected
      await Future.delayed(const Duration(milliseconds: 600));
      _feedItems = _placeholderFeed;
    } catch (e) {
      _errorMessage = 'Failed to load reports. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upvote a report locally and sync to Firestore.
  Future<void> upvoteReport(String reportId) async {
    // TODO: FirebaseFirestore.instance
    //     .collection('reports')
    //     .doc(reportId)
    //     .update({'likes': FieldValue.increment(1)});
    notifyListeners();
  }

  /// Submit a new citizen issue and add it to the top of the local feed.
  Future<void> submitIssue({
    required List<String> categories,
    String? description,
    required bool hasAudioDescription,
    required String address,
    required List<String> attachedMedia,
    required String priorityLabel,
    required bool isAnonymous,
  }) async {
    // TODO: Send this payload to Firestore/API so admins receive the report.
    final firstCategory = categories.isNotEmpty ? categories.first : 'General';
    final icon = _iconForCategory(firstCategory);
    final details = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Audio description attached by citizen.';

    final mediaSummary = attachedMedia.isEmpty
        ? 'No media attached'
        : '${attachedMedia.length} media attachment(s)';

    final identity = isAnonymous ? 'Anonymous' : 'Citizen';

    final report = ReportItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '$firstCategory issue reported',
      description:
          '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
      category: categories.join(' • ').toUpperCase(),
      timeLocation: 'Just now • $address',
      status: ReportStatus.submitted,
      icon: icon,
      likes: 0,
      comments: 0,
      address: address,
      priorityLabel: priorityLabel,
      isAnonymous: isAnonymous,
      hasAudioDescription: hasAudioDescription,
      attachedMedia: attachedMedia,
    );

    _feedItems = [report, ..._feedItems];
    _myReportedItems = [report, ..._myReportedItems];
    notifyListeners();
  }

  /// Update an existing citizen-submitted issue while it is still in Submitted status.
  Future<bool> updateSubmittedIssue({
    required String issueId,
    required List<String> categories,
    String? description,
    required bool hasAudioDescription,
    required String address,
    required List<String> attachedMedia,
    required String priorityLabel,
    required bool isAnonymous,
  }) async {
    final index = _myReportedItems.indexWhere((item) => item.id == issueId);
    if (index == -1) {
      return false;
    }

    final existing = _myReportedItems[index];
    if (existing.status != ReportStatus.submitted) {
      return false;
    }

    final firstCategory = categories.isNotEmpty ? categories.first : 'General';
    final icon = _iconForCategory(firstCategory);
    final details = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Audio description attached by citizen.';

    final mediaSummary = attachedMedia.isEmpty
        ? 'No media attached'
        : '${attachedMedia.length} media attachment(s)';

    final identity = isAnonymous ? 'Anonymous' : 'Citizen';

    final updated = ReportItem(
      id: existing.id,
      title: '$firstCategory issue reported',
      description:
          '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
      category: categories.join(' • ').toUpperCase(),
      timeLocation: 'Updated just now • $address',
      status: existing.status,
      icon: icon,
      likes: existing.likes,
      comments: existing.comments,
      address: address,
      priorityLabel: priorityLabel,
      isAnonymous: isAnonymous,
      hasAudioDescription: hasAudioDescription,
      attachedMedia: attachedMedia,
    );

    _myReportedItems[index] = updated;

    final feedIndex = _feedItems.indexWhere((item) => item.id == issueId);
    if (feedIndex != -1) {
      _feedItems[feedIndex] = updated;
    }

    notifyListeners();
    return true;
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'infrastructure':
        return Icons.construction;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'security':
        return Icons.security;
      case 'land':
        return Icons.landscape_outlined;
      case 'justice':
        return Icons.gavel_outlined;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  // Placeholder data

  static final List<ReportItem> _placeholderFeed = [
    ReportItem(
      id: '1',
      title: 'Broken Pipe in Kirehe Main St.',
      description:
          'Large water leak near the central market causing low pressure for three blocks.',
      category: 'INFRASTRUCTURE',
      timeLocation: '2h ago • Central Market',
      status: ReportStatus.resolved,
      icon: Icons.plumbing,
      likes: 128,
      comments: 12,
    ),
    ReportItem(
      id: '2',
      title: 'Street Light Failure - Sector 4',
      description:
          'Three street lights are out near the primary school, a safety concern for evening classes.',
      category: 'UTILITIES',
      timeLocation: '5h ago • Primary School Zone',
      status: ReportStatus.inProgress,
      icon: Icons.lightbulb_outline,
      likes: 45,
      comments: 3,
    ),
    ReportItem(
      id: '3',
      title: 'Pothole on Kigali Road',
      description:
          'Large pothole causing traffic slowdowns and risk of vehicle damage near the roundabout.',
      category: 'ROADS',
      timeLocation: '1d ago • Kigali Road',
      status: ReportStatus.reported,
      icon: Icons.edit_road_outlined,
      likes: 67,
      comments: 8,
    ),
  ];
}
