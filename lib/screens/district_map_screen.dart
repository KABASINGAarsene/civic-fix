import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DistrictMapScreen extends StatefulWidget {
  const DistrictMapScreen({Key? key}) : super(key: key);

  @override
  State<DistrictMapScreen> createState() => _DistrictMapScreenState();
}

class _DistrictMapScreenState extends State<DistrictMapScreen> {
  int _bottomNavIndex = 2; // Map is index 2
  String? _adminDistrict;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminDistrict();
  }

  Future<void> _loadAdminDistrict() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _adminDistrict = doc.data()?['district'];
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading admin district: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
        : Stack(
        children: [
          // Fullscreen Map Placeholder
          _buildFullscreenMap(),

          // Territory Isolation Banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTerritoryBanner(),
          ),

          // Real-time Firestore Map Pins
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issues')
                .where('district', isEqualTo: _adminDistrict)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final docs = snapshot.data!.docs;
              return Stack(
                children: docs.asMap().entries.map((entry) {
                  final data = entry.value.data() as Map<String, dynamic>;
                  final lat = data['latitude'] as double?;
                  final lng = data['longitude'] as double?;
                  
                  if (lat == null || lng == null) return const SizedBox.shrink();

                  // Simple projection for demonstration on a static image
                  // In a real app, this would be handled by a Google Maps widget
                  final topOffset = 150 + (entry.key * 60) % 250; 
                  final leftOffset = 50 + (entry.key * 110) % 280;

                  return Positioned(
                    top: topOffset.toDouble(),
                    left: leftOffset.toDouble(),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context, 
                          '/admin-ticket-detail',
                          arguments: {
                            'data': data,
                            'ticketId': entry.value.id,
                          },
                        );
                      },
                      child: _buildMapPin(
                        entry.key + 1 > 9 ? "!" : (entry.key + 1).toString(), 
                        _getPriorityColor(data['priority'])
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Bottom Info Sheet
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildBottomMapCard(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 180), // Above the bottom sheet
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1F2937),
          child: const Icon(Icons.layers, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Toggling Heatmap Layer...')),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111827),
      elevation: 0,
      title: const Text(
        'District Field Map',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFullscreenMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        image: DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color(0xFF1F2937),
            BlendMode.multiply, // Darken map for dark mode feel
          ),
        ),
      ),
    );
  }

  Widget _buildTerritoryBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security, color: Color(0xFF60A5FA), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Exclusive Territory View',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Viewing issues assigned to ${_adminDistrict ?? 'N/A'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority is num) {
      if (priority >= 2) return const Color(0xFFEF4444); // Critical
      if (priority >= 1) return const Color(0xFFF59E0B); // Medium
      return const Color(0xFF10B981); // Low
    }
    return const Color(0xFF3B82F6);
  }

  Widget _buildMapPin(String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          width: 2,
          height: 12,
          color: color,
        ),
      ],
    );
  }

  Widget _buildBottomMapCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('district', isEqualTo: _adminDistrict)
          .snapshots(),
      builder: (context, snapshot) {
        int fieldVisits = 0;
        int resolved = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final status = doc.get('status');
            if (status == 'Field Visit') fieldVisits++;
            if (status == 'Resolved') resolved++;
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF374151)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Field Teams',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$fieldVisits Active visits',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTeamRow('Field Support Teams', '$fieldVisits Active in ${_adminDistrict ?? ''}', true),
              const SizedBox(height: 12),
              _buildTeamRow('Resolved Issues', '$resolved Closed today', true),
            ],
          ),
        );
      }
    );
  }

  Widget _buildTeamRow(String name, String location, bool isOnline) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isOnline ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          location,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 12,
          ),
        ),
      ],
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
            // Already here
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
