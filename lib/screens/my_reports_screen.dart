import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'issue_detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({Key? key}) : super(key: key);

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Submitted', 'Received', 'Assigned', 'Field Visit', 'Resolved'];

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':   return const Color(0xFF2563EB); // Blue
      case 'Received':    return const Color(0xFF7C3AED); // Purple
      case 'Assigned':    return const Color(0xFFF59E0B); // Amber
      case 'Field Visit': return const Color(0xFFD97706); // Orange
      case 'Resolved':    return const Color(0xFF10B981); // Green
      case 'Open':        return const Color(0xFF2563EB); // Legacy support
      case 'In Progress': return const Color(0xFFF59E0B); // Legacy support
      default:            return const Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFD1D5DB)),
                        SizedBox(height: 16),
                        Text('No reports yet', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Tap + to submit a new issue', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                        color: _getStatusColor(status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(status.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: _getStatusColor(status), letterSpacing: 0.8)),
                    ),
                    const SizedBox(width: 8),
                    Text(shortId, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ]),
                  const SizedBox(height: 6),
                  Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(width: 6, height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: _getStatusColor(status))),
                    Expanded(child: Text(statusNote,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
    child: Icon(_getCategoryIcon(category), color: const Color(0xFFD1D5DB), size: 28));

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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('My Reports',
        style: TextStyle(color: Color(0xFF111827), fontSize: 18, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [IconButton(icon: const Icon(Icons.search, color: Color(0xFF111827)), onPressed: () {})],
    );
  }

  Widget _buildFilterPills() {
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
                color: isSelected ? const Color(0xFF0A4DDE) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/capture-evidence'),
      child: Container(
        width: 50, height: 50,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A4DDE), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFF0A4DDE).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF0A4DDE) : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFF0A4DDE) : const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}
