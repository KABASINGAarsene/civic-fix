import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:district_direct/l10n/app_localizations.dart';

class IssuesManagementScreen extends StatefulWidget {
  const IssuesManagementScreen({Key? key}) : super(key: key);

  @override
  State<IssuesManagementScreen> createState() => _IssuesManagementScreenState();
}

class _IssuesManagementScreenState extends State<IssuesManagementScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 1;
  String _selectedCategory = 'All';
  late TabController _tabController;
  String? _adminDistrict;
  bool _isLoadingDistrict = true;
  StreamSubscription? _statusSubscription;

  final List<String> _statuses = ['Submitted', 'Assigned', 'Field Visit', 'Resolved'];

  final List<String> _categories = [
    'All',
    'Infrastructure',
    'Health',
    'Security',
    'Land',
    'Education',
    'Justice',
    'Social Welfare'
  ];

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'Submitted':
        return l10n.submittedStatus;
      case 'Received':
        return l10n.receivedStatus;
      case 'Assigned':
        return l10n.assignedStatus;
      case 'Field Visit':
        return l10n.fieldVisitStatus;
      case 'Resolved':
        return l10n.resolvedStatus;
      default:
        return status;
    }
  }

  String _categoryLabel(String category, AppLocalizations l10n) {
    if (category == 'All') return l10n.allFilter;
    return category;
  }

  Color _statusSemanticColor(String status, ColorScheme scheme) {
    switch (status.trim().toLowerCase()) {
      case 'submitted':
      case 'open':
        return scheme.primary;
      case 'received':
      case 'assigned':
      case 'field visit':
      case 'in progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return scheme.tertiary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String? _extractDistrict(Map<String, dynamic>? data) {
    if (data == null) return null;
    const candidateKeys = [
      'district',
      'assignedDistrict',
      'assigned_district',
      'adminDistrict',
      'districtName',
      'district_name',
    ];
    for (final key in candidateKeys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAdminDistrict();
  }

  Future<void> _loadAdminDistrict() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _adminDistrict = _extractDistrict(doc.data());
            _isLoadingDistrict = false;
          });
          _setupStatusAutomation();
        } else {
          setState(() => _isLoadingDistrict = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading admin district: $e');
      setState(() => _isLoadingDistrict = false);
    }
  }

  void _setupStatusAutomation() {
    if (_adminDistrict == null) return;
    
    // Auto-update 'Submitted' or 'Open' to 'Received'
    _statusSubscription = FirebaseFirestore.instance
        .collection('issues')
        .where('district', isEqualTo: _adminDistrict)
        .where('status', whereIn: ['Submitted', 'Open'])
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'status': 'Received'});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoadingDistrict
          ? Center(child: CircularProgressIndicator(color: scheme.primary))
          : Column(
              children: [
                _buildCategoryFilters(),
                _buildStatusTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _statuses.map((status) => _buildIssuesList(status)).toList(),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.search, color: scheme.onSurface),
        onPressed: () {},
      ),
      title: Text(
        l10n.issuesManagementTitle,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: const [
        SizedBox(width: 48), // Spacer to balance the leading search icon
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _categories[index] == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = _categories[index];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? scheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? scheme.primary : scheme.outline.withValues(alpha: 0.45),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  _categoryLabel(_categories[index], l10n),
                  style: TextStyle(
                    color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTabBar() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selectedStatus = _statuses[_tabController.index.clamp(0, _statuses.length - 1)];
    final selectedColor = _statusSemanticColor(selectedStatus, scheme);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.45), width: 1),
        ),
      ),
      child: TabBar(
        isScrollable: true,
        controller: _tabController,
        indicatorColor: selectedColor,
        indicatorWeight: 3,
        labelColor: selectedColor,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: _statuses.map((s) => Tab(text: _statusLabel(s, l10n))).toList(),
      ),
    );
  }

  Widget _buildIssuesList(String status) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    if (_adminDistrict == null) {
      return Center(child: Text(l10n.noDistrictAssigned, style: TextStyle(color: scheme.error)));
    }

    // ── FALLBACK FOR LEGACY DATA ──
    // Older reports used 'Open' instead of 'Submitted'.
    // We handle the first tab as both [Submitted, Open]
    
    Query query = FirebaseFirestore.instance
        .collection('issues')
        .where('district', isEqualTo: _adminDistrict);

    if (_selectedCategory != 'All') {
      query = query.where('category', isEqualTo: _selectedCategory);
    }

    if (status == 'Submitted') {
      query = query.where('status', whereIn: ['Submitted', 'Open', 'Received']);
    } else {
      query = query.where('status', isEqualTo: status);
    }

    query = query.orderBy('timestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: scheme.error)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: scheme.primary));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_outlined, size: 48, color: scheme.surfaceContainerHigh),
                const SizedBox(height: 16),
                Text('${l10n.noIssuesIn} ${_statusLabel(status, l10n)}', style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final id = doc.id;
            return _buildIssueCard(data, id);
          },
        );
      },
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> data, String ticketId) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final status = (data['status'] ?? 'Submitted').toString();
    final statusColor = _statusSemanticColor(status, scheme);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/admin-ticket-detail',
          arguments: {
            'data': data,
            'ticketId': ticketId,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: data['photo_url'] != null
                  ? Image.network(
                      data['photo_url'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildItemPlaceholder(data['category']),
                    )
                  : _buildItemPlaceholder(data['category']),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(data['priority']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_getPriorityLabel(data['priority']).toUpperCase()} ${l10n.prioritySuffix}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['title'] ?? l10n.untitledIssue,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data['district'] ?? ''} / ${data['sector'] ?? ''}',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPlaceholder(String? category) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      color: scheme.surfaceContainerHigh,
      child: Icon(_getCategoryIcon(category), color: scheme.primary.withOpacity(0.5), size: 30),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Infrastructure': return Icons.construction;
      case 'Health':         return Icons.health_and_safety;
      case 'Security':       return Icons.security;
      case 'Land':           return Icons.landscape;
      case 'Education':      return Icons.school;
      case 'Justice':        return Icons.gavel;
      case 'Social Welfare': return Icons.people;
      default:               return Icons.miscellaneous_services;
    }
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority is num) {
      if (priority >= 2) return const Color(0xFF7F1D1D); // Critical
      if (priority >= 1) return const Color(0xFFB45309); // Medium
      return const Color(0xFF065F46); // Low
    }
    // Legacy string support
    if (priority == 'Critical') return const Color(0xFF7F1D1D);
    return const Color(0xFF1E3A8A);
  }

  String _getPriorityLabel(dynamic priority) {
    if (priority is num) {
      if (priority >= 2) return 'CRITICAL';
      if (priority >= 1) return 'MEDIUM';
      return 'LOW';
    }
    return (priority?.toString() ?? 'MEDIUM');
  }

  Widget _buildBottomNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.35))),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (index == 1) {
            // Already here
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-map');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/admin-chats');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/admin-profile');
          } else {
            setState(() {
              _bottomNavIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: l10n.adminDashboardLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: l10n.adminIssuesLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: l10n.adminMapLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.forum), label: l10n.chatsLabel),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.profileLabel),
        ],
      ),
    );
  }
}
