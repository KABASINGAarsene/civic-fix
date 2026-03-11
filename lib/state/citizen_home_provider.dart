import 'package:flutter/material.dart';
import '../models/report_model.dart';

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
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportItem> get feedItems => _feedItems;
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
