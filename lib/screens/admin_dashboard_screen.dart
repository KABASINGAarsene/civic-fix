import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _bottomNavIndex = 0;
  String? _adminDistrict;
  bool _isLoading = true;
  StreamSubscription? _statusSubscription;

  // Stats
  int _totalReceived = 0;
  int _inProgress = 0;
  int _resolved = 0;
  Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Get Admin District
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _adminDistrict = userDoc.data()?['district'];
            _isLoading = false;
          });
          _setupStatusAutomation();
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading admin profile: $e');
      setState(() => _isLoading = false);
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
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827), // Dark background
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('issues')
                .where('district', isEqualTo: _adminDistrict)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
              }

              final docs = snapshot.data?.docs ?? [];
              
              // Calculate everything dynamically from snapshot
              int resolvedCount = 0;
              int inProgressCount = 0;
              int submittedCount = 0;
              Map<String, int> tempCategoryCounts = {};

              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final status = data['status'] ?? 'Submitted';
                final category = data['category'] ?? 'Other';

                if (status == 'Resolved') {
                  resolvedCount++;
                } else if (status == 'Assigned' || status == 'Field Visit') {
                  inProgressCount++;
                } else if (status == 'Submitted' || status == 'Open' || status == 'Received') {
                  submittedCount++;
                }

                tempCategoryCounts[category] = (tempCategoryCounts[category] ?? 0) + 1;
              }

              _totalReceived = submittedCount;
              _resolved = resolvedCount;
              _inProgress = inProgressCount;
              _categoryCounts = tempCategoryCounts;

              return RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: const Color(0xFF3B82F6),
                backgroundColor: const Color(0xFF1F2937),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopStatsGrid(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('District Activity', 'View Map'),
                        const SizedBox(height: 12),
                        _buildHeatmapCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Category Distribution', ''),
                        const SizedBox(height: 12),
                        _buildCategoryDistributionCard(),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Recent Performance', ''),
                        const SizedBox(height: 12),
                        _buildMonthlyPerformanceCard(docs),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111827),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'DistrictDirect ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Rwanda',
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadDashboardData,
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // Helper for performance card
  Map<String, Map<String, int>> _calculateMonthlyPerformance(List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, int>> stats = {};
    final now = DateTime.now();
    
    // Last 6 months labels
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    List<String> last6Months = [];
    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      last6Months.add(months[m.month - 1]);
    }

    // Initialize
    for (var m in last6Months) {
      stats[m] = {'received': 0, 'solved': 0};
    }

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp == null) continue;

      final date = timestamp.toDate();
      final monthName = months[date.month - 1];

      if (stats.containsKey(monthName)) {
        stats[monthName]!['received'] = stats[monthName]!['received']! + 1;
        if (data['status'] == 'Resolved') {
          stats[monthName]!['solved'] = stats[monthName]!['solved']! + 1;
        }
      }
    }
    return stats;
  }

  Widget _buildTopStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'RECEIVED',
          value: _totalReceived.toString(),
          trend: 'Live',
          trendColor: const Color(0xFF10B981),
          icon: Icons.analytics,
          iconBgColor: const Color(0xFF2563EB),
        ),
        _buildStatCard(
          title: 'IN-PROGRESS',
          value: _inProgress.toString(),
          trend: 'Active',
          trendColor: const Color(0xFFF59E0B),
          icon: Icons.assignment_late,
          iconBgColor: const Color(0xFFF59E0B),
        ),
        _buildStatCard(
          title: 'RESOLVED TOTAL',
          value: _resolved.toString(),
          trend: 'Check',
          trendColor: const Color(0xFF10B981),
          icon: Icons.check_circle_outline,
          iconBgColor: const Color(0xFF10B981),
        ),
        _buildStatCard(
          title: 'MY DISTRICT',
          value: _adminDistrict ?? 'N/A',
          trend: 'Safe',
          trendColor: const Color(0xFF60A5FA),
          icon: Icons.location_city,
          iconBgColor: const Color(0xFF6B7280),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String trend,
    required Color trendColor,
    required IconData icon,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconBgColor, size: 20),
              Text(
                trend,
                style: TextStyle(
                  color: trendColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action.isNotEmpty)
          Text(
            action,
            style: const TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildHeatmapCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('district', isEqualTo: _adminDistrict)
          .snapshots(),
      builder: (context, snapshot) {
        List<Marker> markers = [];
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          for (int i = 0; i < docs.length && i < 10; i++) { // Limit to 10 markers on dashboard
            final data = docs[i].data() as Map<String, dynamic>;
            final lat = data['latitude'] as double?;
            final lng = data['longitude'] as double?;
            
            if (lat != null && lng != null) {
              markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 40,
                  height: 40,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(data['priority']),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getPriorityColor(data['priority']).withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        }

        const LatLng kigaliCenter = LatLng(-1.9536, 29.8739);

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: kigaliCenter,
                    initialZoom: 10.0,
                    interactionOptions: InteractionOptions(
                      flags: ~InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'civic.fix',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                // Overlay gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                // Hotspot Overlay Box
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT HOTSPOT',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _adminDistrict ?? 'Current District',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_totalReceived Reports Found',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCategoryDistributionCard() {
    // 1. Define category colors mapping
    final categoryColors = {
      'Infrastructure': const Color(0xFF3B82F6),
      'Health': const Color(0xFF10B981),
      'Security': const Color(0xFFF59E0B),
      'Land': const Color(0xFF8B5CF6),
      'Education': const Color(0xFFEC4899),
      'Justice': const Color(0xFF14B8A6),
      'Social Welfare': const Color(0xFF6366F1),
      'Other': const Color(0xFF6B7280),
    };

    final allCategories = categoryColors.keys.toList();
    final total = _categoryCounts.values.fold(0, (sum, count) => sum + count);

    // 2. Build cumulative segments logic
    // We reverse sort by value to make the donut slices look organized, or just follow the order
    List<Widget> segments = [];
    if (total > 0) {
      double cumulativePercentage = 1.0;
      for (var cat in allCategories) {
        final count = _categoryCounts[cat] ?? 0;
        if (count > 0 || cat == 'Infrastructure') { // Infrastructure as base layer
          segments.add(_buildDonutSegment(
            cumulativePercentage, 
            categoryColors[cat] ?? Colors.grey,
            isBase: cat == 'Infrastructure'
          ));
          cumulativePercentage -= (count / total);
        }
      }
    } else {
      segments.add(_buildDonutSegment(1.0, const Color(0xFF374151), isBase: true));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Dynamic Donut Chart
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...segments, // Removed .reversed so smaller segments are on TOP
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Legend with all 7 categories in a 2-column Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: allCategories.map((cat) {
              final count = _categoryCounts[cat] ?? 0;
              final percent = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
              return _buildCategoryLegend(
                cat, 
                categoryColors[cat] ?? Colors.grey, 
                count.toString(), 
                '$percent%'
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutSegment(double value, Color color, {bool isBase = false}) {
    return SizedBox(
      width: 140,
      height: 140,
      child: CircularProgressIndicator(
        value: value > 0 ? value : 0.05, // Show minor segment even if zero for visual placeholder
        strokeWidth: 16,
        color: color,
        backgroundColor: isBase ? const Color(0xFF111827) : Colors.transparent,
      ),
    );
  }

  Widget _buildCategoryLegend(String name, Color color, String count, String percent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$count ($percent)',
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyPerformanceCard(List<QueryDocumentSnapshot> docs) {
    final stats = _calculateMonthlyPerformance(docs);
    final monthKeys = stats.keys.toList();

    // Scale heights based on max value to fit card (max 100 height)
    int maxVal = 0;
    for (var m in monthKeys) {
      if (stats[m]!['received']! > maxVal) maxVal = stats[m]!['received']!;
    }
    double scale = maxVal > 0 ? 100 / maxVal : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: monthKeys.map((m) {
              return _buildBarGroup(
                (stats[m]!['received']! * scale).clamp(5, 100).toDouble(),
                (stats[m]!['solved']! * scale).clamp(2, 100).toDouble(),
                m
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Received',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
              const SizedBox(width: 24),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Solved',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarGroup(double receivedHeight, double solvedHeight, String month) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 8,
              height: receivedHeight,
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: solvedHeight,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          month,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937),
        border: Border(top: BorderSide(color: Color(0xFF374151))),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-issues');
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
          // We will wire this to other admin routes later
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
