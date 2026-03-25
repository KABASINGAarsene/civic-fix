import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dashboard_models.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      final snapshot = await _firestore.collection('reports').get();
      final docs = snapshot.docs;

      final total = docs.length;
      final submitted = docs.where((d) => d.data()['status'] == 'submitted').length;
      final inProgress = docs.where((d) => d.data()['status'] == 'inProgress').length;
      final resolved = docs.where((d) => d.data()['status'] == 'resolved').length;

      final resolvedDurations = docs
          .where((d) => d.data()['status'] == 'resolved')
          .map((d) {
            final createdAt = (d.data()['createdAt'] as Timestamp?)?.toDate();
            final updatedAt = (d.data()['updatedAt'] as Timestamp?)?.toDate();
            if (createdAt == null || updatedAt == null) return 0;
            return updatedAt.difference(createdAt).inHours;
          })
          .where((hours) => hours > 0)
          .toList();

      final avgHours = resolvedDurations.isEmpty
          ? 0
          : resolvedDurations.reduce((a, b) => a + b) / resolvedDurations.length;
      final avgDays = (avgHours / 24).toStringAsFixed(1);

      _stats = [
        AdminStat(
          label: 'TOTAL RECEIVED',
          value: total.toString(),
          trend: '$submitted newly submitted',
          trendUp: null,
          icon: Icons.insert_chart_outlined,
          color: const Color(0xFF1E5EFF),
        ),
        AdminStat(
          label: 'IN PROGRESS',
          value: inProgress.toString(),
          trend: 'Active cases',
          trendUp: null,
          icon: Icons.assignment_late_outlined,
          color: const Color(0xFFFFC107),
        ),
        AdminStat(
          label: 'RESOLVED',
          value: resolved.toString(),
          trend: 'Closed reports',
          trendUp: true,
          icon: Icons.check_circle_outline,
          color: const Color(0xFF28A745),
        ),
        AdminStat(
          label: 'AVG. RESOLUTION',
          value: '$avgDays d',
          trend: 'Resolved reports only',
          trendUp: null,
          icon: Icons.access_time_outlined,
          color: const Color(0xFFDC3545),
        ),
      ];
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
      final snapshot = await _firestore
          .collection('reports')
          .where('status', isEqualTo: 'submitted')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .get();

      _inbox = snapshot.docs.map((doc) {
        final data = doc.data();
        final priorityLabel = (data['priorityLabel'] as String? ?? 'LOW').toUpperCase();
        final tagColor = switch (priorityLabel) {
          'HIGH' => const Color(0xFFDC3545),
          'MEDIUM' => const Color(0xFFFFC107),
          _ => const Color(0xFF17A2B8),
        };

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final address = (data['address'] as String?) ?? 'Unknown location';

        return PriorityIssue(
          id: doc.id,
          title: (data['title'] as String?) ?? 'Issue reported',
          subtitle: '${_timeAgo(createdAt)} • $address',
          tag: priorityLabel,
          tagColor: tagColor,
          icon: Icons.flag_outlined,
          upvotes: (data['likes'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      _inboxError = 'Failed to load priority issues.';
    } finally {
      _inboxLoading = false;
      notifyListeners();
    }
  }

  /// Assign an issue to an official.
  Future<void> assignIssue(String issueId) async {
    final uid = _auth.currentUser?.uid ?? 'admin';
    await _firestore.collection('reports').doc(issueId).update({
      'assignedTo': 'Local Authority',
      'assignedToId': uid,
      'status': 'inProgress',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await loadAll();
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
      final now = DateTime.now();
      final labels = <String>[];
      final resolvedMap = <String, int>{};
      final receivedMap = <String, int>{};

      for (var i = 5; i >= 0; i--) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final label = _monthLabel(monthDate.month);
        labels.add(label);
        resolvedMap[label] = 0;
        receivedMap[label] = 0;
      }

      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(500)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        if (createdAt == null) continue;

        final label = _monthLabel(createdAt.month);
        if (!receivedMap.containsKey(label)) continue;

        receivedMap[label] = (receivedMap[label] ?? 0) + 1;
        if ((data['status'] as String?) == 'resolved') {
          resolvedMap[label] = (resolvedMap[label] ?? 0) + 1;
        }
      }

      _chartData = labels
          .map((label) => MonthData(label, resolvedMap[label] ?? 0, receivedMap[label] ?? 0))
          .toList();
    } catch (e) {
      _chartError = 'Failed to load chart data.';
    } finally {
      _chartLoading = false;
      notifyListeners();
    }
  }

  // Issues Management State

  List<AdminIssue> _allIssues = [];
  bool _issuesLoading = false;
  String? _issuesError;

  List<AdminIssue> get allIssues => _allIssues;
  bool get issuesLoading => _issuesLoading;
  String? get issuesError => _issuesError;

  Future<void> loadIssues() async {
    _issuesLoading = true;
    _issuesError = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      _allIssues = snapshot.docs.map((doc) {
        final data = doc.data();
        final status = (data['status'] as String?) ?? 'submitted';
        final priorityLabel = (data['priorityLabel'] as String? ?? 'LOW').toUpperCase();
        final category = (data['categories'] as List<dynamic>?)?.isNotEmpty == true
            ? data['categories'][0].toString()
            : (data['category'] as String? ?? 'Infrastructure');

        final priorityColor = switch (priorityLabel) {
          'HIGH' => const Color(0xFFDC3545),
          'MEDIUM' => const Color(0xFFFFC107),
          _ => const Color(0xFF17A2B8),
        };

        final priorityScore = switch (priorityLabel) {
          'HIGH' => 85,
          'MEDIUM' => 65,
          _ => 40,
        };

        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        return AdminIssue(
          id: doc.id,
          title: (data['title'] as String?) ?? 'Issue reported',
          location: (data['address'] as String?) ?? 'Unknown location',
          timeAgo: _timeAgo(createdAt),
          priorityLabel: '$priorityLabel PRIORITY',
          priorityColor: priorityColor,
          priorityScore: priorityScore,
          category: category,
          status: status,
          description: (data['description'] as String?) ?? 'No description provided.',
          address: (data['address'] as String?) ?? 'Unknown location',
          attachedMedia: ((data['attachedMedia'] as List<dynamic>?) ?? [])
              .map((e) => e.toString())
              .toList(),
          hasAudioDescription: (data['hasAudioDescription'] as bool?) ?? false,
          audioPath: (data['audioPath'] as String?),
          citizenId: (data['reporterId'] as String?) ?? '',
        );
      }).toList();
    } catch (e) {
      _issuesError = 'Failed to load issues.';
    } finally {
      _issuesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadStats(), loadInbox(), loadChartData(), loadIssues()]);
  }

  Future<void> updateIssueStatus({
    required String issueId,
    required String status,
    String? adminMessage,
  }) async {
    final uid = _auth.currentUser?.uid ?? 'admin';

    final payload = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'inProgress') {
      payload['assignedTo'] = 'Local Authority';
      payload['assignedToId'] = uid;
    }

    await _firestore.collection('reports').doc(issueId).update(payload);

    final message = adminMessage?.trim();
    if (message != null && message.isNotEmpty) {
      await sendMessage(
        issueId: issueId,
        text: message,
        senderRole: 'admin',
      );
    }

    await loadAll();
  }

  Future<void> sendMessage({
    required String issueId,
    required String text,
    required String senderRole,
  }) async {
    final uid = _auth.currentUser?.uid ?? senderRole;

    await _firestore
        .collection('reports')
        .doc(issueId)
        .collection('messages')
        .add({
      'text': text,
      'senderId': uid,
      'senderRole': senderRole,
      'createdAt': FieldValue.serverTimestamp(),
      'hasImage': false,
    });

    // Mark the report as having an active conversation and store last message
    // preview so the citizen messages list can display it without sub-queries.
    await _firestore.collection('reports').doc(issueId).update({
      'updatedAt': FieldValue.serverTimestamp(),
      'hasConversation': true,
      'lastMessageText': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderRole': senderRole,
    });

    // Notify the citizen when admin sends a message.
    if (senderRole == 'admin') {
      final reportSnap =
          await _firestore.collection('reports').doc(issueId).get();
      final citizenId = reportSnap.data()?['reporterId'] as String?;
      if (citizenId != null && citizenId.isNotEmpty && citizenId != 'guest') {
        final preview = text.length > 100 ? '${text.substring(0, 100)}…' : text;
        await _firestore
            .collection('notifications')
            .doc(citizenId)
            .collection('items')
            .add({
          'title': 'New Message from Admin',
          'body': preview,
          'tag': 'MESSAGE',
          'issueId': issueId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _monthLabel(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }

  // Placeholder factories retained only for fallback visuals when backend has no data.

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

  static final List<AdminIssue> _placeholderIssues = [
    // Submitted
    AdminIssue(
      id: 'DD-2045',
      title: 'Land cracking – drought damage',
      location: 'Kirehe / Gatore Cell',
      timeAgo: '4h ago',
      priorityLabel: 'HIGH PRIORITY',
      priorityColor: Color(0xFFDC3545),
      priorityScore: 85,
      category: 'Infrastructure',
      status: 'submitted',
    ),
    AdminIssue(
      id: 'DD-2046',
      title: 'Broken water pipe overflow',
      location: 'Nyagatare / Gatunda',
      timeAgo: '6h ago',
      priorityLabel: 'MEDIUM PRIORITY',
      priorityColor: Color(0xFFFFC107),
      priorityScore: 72,
      category: 'Infrastructure',
      status: 'submitted',
    ),
    AdminIssue(
      id: 'DD-2047',
      title: 'Street light outage – main road',
      location: 'Musanze / Busogo Sector',
      timeAgo: '10h ago',
      priorityLabel: 'HIGH PRIORITY',
      priorityColor: Color(0xFFDC3545),
      priorityScore: 91,
      category: 'Infrastructure',
      status: 'submitted',
    ),
    AdminIssue(
      id: 'DD-2048',
      title: 'Waste collection point overflow',
      location: 'Huye / Ngoma Sector',
      timeAgo: '14h ago',
      priorityLabel: 'LOW PRIORITY',
      priorityColor: Color(0xFF17A2B8),
      priorityScore: 45,
      category: 'Infrastructure',
      status: 'submitted',
    ),
    // In Progress
    AdminIssue(
      id: 'DD-2040',
      title: 'Road pothole – arterial road',
      location: 'Gasabo / Kimironko',
      timeAgo: '1d ago',
      priorityLabel: 'HIGH PRIORITY',
      priorityColor: Color(0xFFDC3545),
      priorityScore: 88,
      category: 'Infrastructure',
      status: 'inProgress',
    ),
    AdminIssue(
      id: 'DD-2041',
      title: 'Blocked drainage channel',
      location: 'Kicukiro / Gahanga',
      timeAgo: '2d ago',
      priorityLabel: 'MEDIUM PRIORITY',
      priorityColor: Color(0xFFFFC107),
      priorityScore: 60,
      category: 'Infrastructure',
      status: 'inProgress',
    ),
    // Resolved
    AdminIssue(
      id: 'DD-2035',
      title: 'Broken streetlight – sector 3',
      location: 'Kirehe / Nasho Cell',
      timeAgo: '3d ago',
      priorityLabel: 'LOW PRIORITY',
      priorityColor: Color(0xFF17A2B8),
      priorityScore: 40,
      category: 'Infrastructure',
      status: 'resolved',
    ),
    AdminIssue(
      id: 'DD-2036',
      title: 'Water pipe leak – community tap',
      location: 'Nyagatare / Rwimiyaga',
      timeAgo: '4d ago',
      priorityLabel: 'MEDIUM PRIORITY',
      priorityColor: Color(0xFFFFC107),
      priorityScore: 68,
      category: 'Infrastructure',
      status: 'resolved',
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
