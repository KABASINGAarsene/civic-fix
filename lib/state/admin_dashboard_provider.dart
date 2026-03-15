import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

class AdminDashboardProvider extends ChangeNotifier {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;

  int get selectedTab => _selectedTab;
  int get selectedNavIndex => _selectedNavIndex;

  void setTab(int index) {
    _selectedTab = index;
    // TODO: Filter inbox and stats by category tab when index changes
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  // KPI Stats
  List<AdminStat> _stats = [];
  bool _statsLoading = false;
  String? _statsError;

  List<AdminStat> get stats => _stats;
  bool get statsLoading => _statsLoading;
  String? get statsError => _statsError;

  Future<void> loadStats() async {
    _statsLoading = true;
    _statsError = null;
    notifyListeners();

    try {
      // TODO: Replace with real Firestore aggregation:
      //
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('reports')
      //     .get();
      //
      // final total = snapshot.docs.length;
      // final inProgress = snapshot.docs
      //     .where((d) => d['status'] == 'inProgress').length;
      // etc.

      await Future.delayed(const Duration(milliseconds: 500));
      _stats = _placeholderStats;
    } catch (e) {
      _statsError = 'Failed to load statistics.';
    } finally {
      _statsLoading = false;
      notifyListeners();
    }
  }

  // Priority Inbox State

  List<PriorityIssue> _inbox = [];
  bool _inboxLoading = false;
  String? _inboxError;

  List<PriorityIssue> get inbox => _inbox;
  bool get inboxLoading => _inboxLoading;
  String? get inboxError => _inboxError;

  Future<void> loadInbox() async {
    _inboxLoading = true;
    _inboxError = null;
    notifyListeners();

    try {
      // TODO: Replace with real Firestore query:
      //
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('reports')
      //     .where('status', isEqualTo: 'reported')
      //     .orderBy('upvotes', descending: true)
      //     .limit(10)
      //     .get();
      //
      // _inbox = snapshot.docs
      //     .map((doc) => PriorityIssue.fromFirestore(doc))
      //     .toList();

      await Future.delayed(const Duration(milliseconds: 500));
      _inbox = _placeholderInbox;
    } catch (e) {
      _inboxError = 'Failed to load priority issues.';
    } finally {
      _inboxLoading = false;
      notifyListeners();
    }
  }

  /// Assign an issue to an official.
  Future<void> assignIssue(String issueId) async {
    // TODO: FirebaseFirestore.instance
    //     .collection('reports')
    //     .doc(issueId)
    //     .update({'assignedTo': officialId, 'status': 'inProgress'});
    notifyListeners();
  }

  /// Add a newly submitted citizen report to the admin inbox.
  void addSubmittedIssue({
    required String title,
    required String subtitle,
    required String priorityLabel,
  }) {
    final tag = priorityLabel.toUpperCase();

    final tagColor = switch (tag) {
      'HIGH' => const Color(0xFFDC3545),
      'MEDIUM' => const Color(0xFF17A2B8),
      _ => const Color(0xFFFFC107),
    };

    final issue = PriorityIssue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      tag: tag,
      tagColor: tagColor,
      icon: Icons.flag_outlined,
      upvotes: 0,
    );

    _inbox = [issue, ..._inbox];
    notifyListeners();
  }

  // Chart Data State

  List<MonthData> _chartData = [];
  bool _chartLoading = false;
  String? _chartError;

  List<MonthData> get chartData => _chartData;
  bool get chartLoading => _chartLoading;
  String? get chartError => _chartError;

  Future<void> loadChartData() async {
    _chartLoading = true;
    _chartError = null;
    notifyListeners();

    try {
      // TODO: Replace with real Firestore monthly aggregation:
      //
      // Query reports grouped by month — consider using a pre-aggregated
      // 'monthly_stats' collection updated by Cloud Functions for performance.
      //
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('monthly_stats')
      //     .orderBy('month')
      //     .limit(6)
      //     .get();
      //
      // _chartData = snapshot.docs
      //     .map((doc) => MonthData.fromFirestore(doc))
      //     .toList();

      await Future.delayed(const Duration(milliseconds: 500));
      _chartData = _placeholderChart;
    } catch (e) {
      _chartError = 'Failed to load chart data.';
    } finally {
      _chartLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadInbox(), loadChartData()]);
  }

  // Placeholder data

  static final List<AdminStat> _placeholderStats = [
    AdminStat(
      label: 'TOTAL RECEIVED',
      value: '1,240',
      trend: '+12%',
      trendUp: true,
      icon: Icons.insert_chart_outlined,
      color: const Color(0xFF1E5EFF),
    ),
    AdminStat(
      label: 'IN PROGRESS',
      value: '312',
      trend: 'Stable',
      trendUp: null,
      icon: Icons.assignment_late_outlined,
      color: const Color(0xFFFFC107),
    ),
    AdminStat(
      label: 'RESOLVED THIS WEEK',
      value: '89',
      trend: '+8%',
      trendUp: true,
      icon: Icons.check_circle_outline,
      color: const Color(0xFF28A745),
    ),
    AdminStat(
      label: 'AVG. RESOLUTION',
      value: '4.2d',
      trend: '+2d slower',
      trendUp: false,
      icon: Icons.access_time_outlined,
      color: const Color(0xFFDC3545),
    ),
  ];

  static final List<PriorityIssue> _placeholderInbox = [
    PriorityIssue(
      id: 'i1',
      title: 'Water Leak – Kirehe',
      subtitle: '2h ago • Sector 4',
      tag: 'CRITICAL',
      tagColor: const Color(0xFFDC3545),
      icon: Icons.water_drop_outlined,
      upvotes: 64,
    ),
    PriorityIssue(
      id: 'i2',
      title: 'Road Damage – Gasabo',
      subtitle: '5h ago • Main Arterial',
      tag: 'HIGH',
      tagColor: const Color(0xFFFFC107),
      icon: Icons.edit_road_outlined,
      upvotes: 45,
    ),
    PriorityIssue(
      id: 'i3',
      title: 'School Roof Damage',
      subtitle: '1d ago • Nyarugenge',
      tag: 'MEDIUM',
      tagColor: const Color(0xFF17A2B8),
      icon: Icons.school_outlined,
      upvotes: 28,
    ),
  ];

  static const List<MonthData> _placeholderChart = [
    MonthData('Jan', 60, 90),
    MonthData('Feb', 72, 95),
    MonthData('Mar', 55, 80),
    MonthData('Apr', 89, 110),
    MonthData('May', 78, 105),
    MonthData('Jun', 95, 120),
  ];
}
