import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminChatsScreen extends StatefulWidget {
  const AdminChatsScreen({Key? key}) : super(key: key);

  @override
  State<AdminChatsScreen> createState() => _AdminChatsScreenState();
}

class _AdminChatsScreenState extends State<AdminChatsScreen> {
  int _bottomNavIndex = 3;
  final String? _adminUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: _buildAppBar(),
      body: _adminUid == null 
        ? const Center(child: Text('Please log in as admin', style: TextStyle(color: Colors.white)))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('adminUid', isEqualTo: _adminUid)
                .orderBy('lastTimestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                final error = snapshot.error.toString();
                if (error.contains('requires an index')) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 48),
                          const SizedBox(height: 16),
                          const Text('Index Required', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                            'To sort chats by time, Firestore needs a composite index. Please click the link in your console or check the project documentation to enable it.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)));
              }

              final docs = snapshot.data?.docs ?? [];
              
              if (docs.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color(0xFF374151),
                  height: 1,
                  indent: 80,
                ),
                itemBuilder: (context, index) {
                  final chat = docs[index].data() as Map<String, dynamic>;
                  return _buildChatTile(chat);
                },
              );
            },
          ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111827),
      elevation: 0,
      title: const Text(
        'Citizen Messages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildChatTile(Map<String, dynamic> data) {
    final ticketId = data['ticketId'] ?? '';
    final citizenName = data['citizenName'] ?? 'Citizen';
    final lastMessage = data['lastMessage'] ?? '';
    final timestamp = (data['lastTimestamp'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null 
        ? (DateTime.now().difference(timestamp).inDays == 0 
            ? DateFormat('jm').format(timestamp) 
            : DateFormat('MMM d').format(timestamp))
        : '';
    final unread = data['unread'] ?? 0;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/chats', arguments: {
          'isAdmin': true,
          'ticketId': ticketId,
          'citizenName': citizenName,
        }); 
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Avatar Placeholder
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF374151),
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            // Info text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        citizenName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: unread > 0
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF374151),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ticketId.length > 8 ? ticketId.substring(0, 8).toUpperCase() : (ticketId.isEmpty ? 'TICKET' : ticketId),
                          style: const TextStyle(
                            color: Color(0xFFD1D5DB),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            color: unread > 0 ? Colors.white : const Color(0xFF9CA3AF),
                            fontSize: 14,
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.chat_bubble_outline, size: 60, color: Color(0xFF374151)),
          SizedBox(height: 16),
          Text(
            'No active conversations',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Send an update from a ticket to start a chat.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        border: Border(top: BorderSide(color: Color(0xFF374151))),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-issues');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-map');
          } else if (index == 3) {
            // current route
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/admin-profile');
          } else {
            setState(() {
              _bottomNavIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1F2937),
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Issues'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
        ],
      ),
    );
  }
}
