import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../shared/issue_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Submitted', 'Received', 'Assigned', 'Field Visit', 'Resolved'];

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status) {
      case 'Submitted':
      case 'Open':
        return scheme.primary;
      case 'Received':
        return scheme.secondary;
      case 'Assigned':
      case 'In Progress':
        return scheme.tertiary;
      case 'Field Visit':
        return scheme.secondary.withValues(alpha: 0.8);
      case 'Resolved':
        return scheme.primary.withValues(alpha: 0.85);
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildFilterPills(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('issues')
                  .where('reported_by_uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs ?? [];
                if (_selectedFilterIndex != 0) {
                  final filterStatus = _filters[_selectedFilterIndex];
                  docs = docs.where((doc) {
                    final status = (doc.data() as Map<String, dynamic>)['status'] ?? 'Submitted';
                    if (filterStatus == 'Submitted') {
                      return status == 'Submitted' || status == 'Open' || status == 'Received';
                    }
                    return status == filterStatus;
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: scheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports yet',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to submit a new issue',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: docs.length,
                  itemBuilder: (context, index) => _buildCompactCard(docs[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildCustomFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCompactCard(DocumentSnapshot doc) {
    final scheme = Theme.of(context).colorScheme;
    final data          = doc.data() as Map<String, dynamic>;
    final String title  = data['title'] ?? data['description'] ?? 'No title';
    final String status = data['status'] ?? 'Open';
    final String? imageUrl = data['photo_url'];
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final dateStr       = ts != null ? _formatDate(ts.toDate()) : 'Recently';
    final String shortId = '#${doc.id.substring(0, 8).toUpperCase()}';

    String statusNote = '';
    if (status == 'Received')    statusNote = 'Acknowledged by District';
    if (status == 'Assigned')    statusNote = 'Field team assigned';
    if (status == 'Field Visit') statusNote = 'Team is on location';
    if (status == 'Resolved')    statusNote = 'Issue has been resolved';
    if (status == 'Submitted' || status == 'Open') statusNote = 'Awaiting district review';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IssueDetailScreen(data: data, docId: doc.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status, scheme).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(status.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: _getStatusColor(status, scheme), letterSpacing: 0.8)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      shortId,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getStatusColor(status, scheme),
                      )),
                    Expanded(child: Text(statusNote,
                      style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Right: thumbnail
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(data['category']))
                  : _placeholder(data['category']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String? category) => Container(
    width: 64, height: 64,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(
      _getCategoryIcon(category),
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 28,
    ));

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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: scheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'My Reports',
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(icon: Icon(Icons.search, color: scheme.onSurface), onPressed: () {})
      ],
    );
  }

  Widget _buildFilterPills() {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_filters[index],
                style: TextStyle(
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomFAB() {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/capture-evidence'),
      child: Container(
        width: 50, height: 50,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(Icons.add, color: scheme.onPrimary, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', false, () => Navigator.pushNamed(context, '/citizen-home')),
          _navItem(Icons.receipt_long, 'Reports', true, () {}),
          const SizedBox(width: 48),
          _navItem(Icons.chat_bubble_outline, 'Chats', false, () => Navigator.pushNamed(context, '/citizen-chats')),
          _navItem(Icons.person, 'Profile', false, () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              color: active ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
