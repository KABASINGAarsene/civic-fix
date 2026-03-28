import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../shared/issue_detail_screen.dart';

class DistrictFeedScreen extends StatefulWidget {
  const DistrictFeedScreen({Key? key}) : super(key: key);

  @override
  State<DistrictFeedScreen> createState() => _DistrictFeedScreenState();
}

class _DistrictFeedScreenState extends State<DistrictFeedScreen> {
  int _bottomNavIndex = 0;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSector;

  final List<String> _provinces = [
    'Kigali City',
    'Eastern Province',
    'Western Province',
    'Northern Province',
    'Southern Province'
  ];

  final Map<String, List<String>> _provinceToDistricts = {
    'Kigali City': ['Gasabo', 'Kicukiro', 'Nyarugenge'],
    'Eastern Province': ['Bugesera', 'Gatsibo', 'Kayonza', 'Kirehe', 'Ngoma', 'Nyagatare', 'Rwamagana'],
    'Western Province': ['Karongi', 'Ngororero', 'Nyabihu', 'Nyamasheke', 'Rubavu', 'Rusizi', 'Rutsiro'],
    'Northern Province': ['Burera', 'Gakenke', 'Gicumbi', 'Musanze', 'Rulindo'],
    'Southern Province': ['Gisagara', 'Huye', 'Kamonyi', 'Muhanga', 'Nyamagabe', 'Nyanza', 'Nyaruguru', 'Ruhango'],
  };

  final Map<String, List<String>> _districtsAndSectors = {
    'Gasabo': ['Bumbogo', 'Gatsata', 'Gisozi', 'Kacyiru', 'Kimihurura', 'Kimironko', 'Kinyinya', 'Ndera', 'Nduba', 'Remera', 'Rusororo', 'Rutunga'],
    'Nyarugenge': ['Gitega', 'Kanyinya', 'Kigali', 'Kimisagara', 'Mageragere', 'Muhima', 'Nyakabanda', 'Nyamirambo', 'Nyarugenge', 'Rwezamenyo'],
    'Kicukiro': ['Gahanga', 'Gatenga', 'Gikondo', 'Kagarama', 'Kanombe', 'Kicukiro', 'Kigarama', 'Masaka', 'Niboye', 'Nyarugunga'],
    'Rusizi': ['Bugarama', 'Butare', 'Bweyeye', 'Gashonga', 'Giheke', 'Gihundwe', 'Gitambi', 'Kamembe', 'Muganza', 'Mururu', 'Nkanka', 'Nkombo', 'Nkungu', 'Nyakabuye', 'Nyakarenzo', 'Nzahaha', 'Rwimbogo'],
    'Rubavu': ['Bugeshi', 'Busasamana', 'Cyanzarwe', 'Gisenyi', 'Kanama', 'Kanzenze', 'Mudende', 'Nyamyumba', 'Nyundo', 'Rubavu', 'Rugerero', 'Rukoko'],
    'Musanze': ['Busogo', 'Cyuve', 'Gacaca', 'Gashaki', 'Gataraga', 'Kimonyi', 'Kinigi', 'Muhoza', 'Muko', 'Nkotsi', 'Nyange', 'Remera', 'Rwaza', 'Shingiro'],
    'Kirehe': ['Gahara', 'Gatore', 'Kigarama', 'Kirehe', 'Mahama', 'Mpanga', 'Musaza', 'Mushikiri', 'Nasho', 'Nyamugari', 'Nyarubuye'],
    'Bugesera': ['Gashora', 'Juru', 'Kamabuye', 'Ntarama', 'Nyamata', 'Rilima'],
    'Kayonza': ['Gahini', 'Kabare', 'Kabarondo', 'Mukarange', 'Murama', 'Murundi', 'Ndego', 'Nyamirama', 'Rukara', 'Ruramira', 'Rwinkwavu'],
    'Gatsibo': ['Gasange', 'Gatsibo', 'Gitoki', 'Kageyo', 'Kiramuruzi', 'Kiziguro', 'Muhura', 'Murambi', 'Ngarama', 'Nyagihanga', 'Remera', 'Rugarama', 'Rwimbogo'],
    'Nyagatare': ['Gatunda', 'Kiyombe', 'Karama', 'Karangazi', 'Katabagemu', 'Matimba', 'Mimuri', 'Mukama', 'Musheli', 'Nyagatare', 'Rukomo', 'Rwempasha', 'Tabagwe'],
    'Ngoma': ['Gashanda', 'Jarama', 'Karembo', 'Kazo', 'Kibungo', 'Mugesera', 'Murama', 'Mutenderi', 'Remera', 'Rukira', 'Rukumberi', 'Zaza'],
    'Rwamagana': ['Fumbwe', 'Gahengeri', 'Gishari', 'Karenge', 'Kigabiro', 'Muhazi', 'Munyaga', 'Munyiginya', 'Musha', 'Muyumbu', 'Mwulire', 'Nyakariro', 'Nzige', 'Rubona'],
  };

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inHours < 24) {
      if (difference.inHours == 0) return '${difference.inMinutes}m ago';
      return '${difference.inHours}h ago';
    }
    return DateFormat('MMM d, yyyy').format(date);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildReportButton(),
              const SizedBox(height: 16),
              _buildFiltersRow(),
              const SizedBox(height: 24),
              _buildFeedHeader(),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('issues')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  var docs = snapshot.data?.docs ?? [];
                  
                  // Client-side filtering for location if selected
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Filter: Anonymous
                    if (data['is_anonymous'] == true) return false;
                    
                    // Filter: Province
                    if (_selectedProvince != null && data['province'] != _selectedProvince) return false;
                    
                    // Filter: District
                    if (_selectedDistrict != null && data['district'] != _selectedDistrict) return false;
                    
                    // Filter: Sector
                    if (_selectedSector != null && data['sector'] != _selectedSector) return false;

                    return true;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: Text(
                          'No district reports yet. Be the first!',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildFeedCard(docs[index]),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0A4DDE),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'AMAHORO, JEAN',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'DistrictDirect',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF374151),
                size: 20,
              ),
            ),
            Positioned(
              right: 20,
              top: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildReportButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF0A4DDE),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A4DDE).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pushNamed(context, '/capture-evidence');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'REPORT NEW ISSUE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Province Filter
          _buildDropdownFilter(
            label: _selectedProvince ?? 'Province',
            icon: Icons.map,
            items: _provinces,
            value: _selectedProvince,
            onChanged: (val) {
              setState(() {
                _selectedProvince = val;
                _selectedDistrict = null;
                _selectedSector = null;
              });
            },
            onClear: () {
              setState(() {
                _selectedProvince = null;
                _selectedDistrict = null;
                _selectedSector = null;
              });
            },
          ),
          const SizedBox(width: 8),

          // District Filter
          _buildDropdownFilter(
            label: _selectedDistrict ?? 'District',
            icon: Icons.location_on,
            items: _selectedProvince == null ? [] : (_provinceToDistricts[_selectedProvince] ?? []),
            value: _selectedDistrict,
            isDisabled: _selectedProvince == null,
            onChanged: (val) {
              setState(() {
                _selectedDistrict = val;
                _selectedSector = null;
              });
            },
            onClear: () {
              setState(() {
                _selectedDistrict = null;
                _selectedSector = null;
              });
            },
          ),
          const SizedBox(width: 8),

          // Sector Filter
          _buildDropdownFilter(
            label: _selectedSector ?? 'Sector',
            icon: Icons.business,
            items: _selectedDistrict == null ? [] : (_districtsAndSectors[_selectedDistrict] ?? ['Main Sector']),
            value: _selectedSector,
            isDisabled: _selectedDistrict == null,
            onChanged: (val) {
              setState(() {
                _selectedSector = val;
              });
            },
            onClear: () {
              setState(() {
                _selectedSector = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required IconData icon,
    required List<String> items,
    String? value,
    bool isDisabled = false,
    required Function(String?) onChanged,
    required VoidCallback onClear,
  }) {
    bool isActive = value != null;

    return Container(
      height: 36,
      child: PopupMenuButton<String>(
        enabled: !isDisabled,
        onSelected: onChanged,
        itemBuilder: (context) => items
            .map((item) => PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A4DDE) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isActive ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : (isDisabled ? Colors.grey : const Color(0xFF4B5563)),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : (isDisabled ? Colors.grey : const Color(0xFF4B5563)),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ] else if (!isDisabled) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: const Color(0xFF4B5563),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'District Feed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Icon(Icons.map, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 6),
              Text(
                'View Map',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String category = (data['category'] ?? 'Issue')
        .toString()
        .toUpperCase();
    final String status = data['status'] ?? 'Submitted';

    // We use a snippet of the description as the title, or a default
    final String description = data['description'] ?? 'No Description provided';
    final String title = description.length > 30
        ? '${description.substring(0, 30)}...'
        : description;

    final String district = data['district'] ?? 'Unknown Sector';
    final Timestamp? ts = data['timestamp'] as Timestamp?;
    final dateStr = ts != null ? _formatDate(ts.toDate()) : 'Recently';

    final List upvotes = data['upvotes'] ?? [];
    final int likes = upvotes.length;
    final int comments = data['comment_count'] ?? 0;
    final bool showAvatars = likes >= 5;

    // Derived UI info
    Color categoryBgColor = const Color(0xFFF3F4F6);
    Color categoryColor = const Color(0xFF4B5563);
    IconData iconData = _getCategoryIcon(category);

    if (category == 'INFRASTRUCTURE' || category == 'LAND') {
      categoryBgColor = const Color(0xFFFEF3C7);
      categoryColor = const Color(0xFFF59E0B);
    } else if (category == 'UTILITIES' ||
        category == 'EDUCATION' ||
        category == 'HEALTH' ||
        category == 'SOCIAL WELFARE') {
      categoryBgColor = const Color(0xFFDBEAFE);
      categoryColor = const Color(0xFF2563EB);
    } else if (category == 'ENVIRONMENT' || category == 'SECURITY' || category == 'JUSTICE') {
      categoryBgColor = const Color(0xFFD1FAE5);
      categoryColor = const Color(0xFF10B981);
    }

    Color statusColor = const Color(0xFF6B7280);
    IconData statusIcon = Icons.info;

    if (status == 'RESOLVED') {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle;
    } else if (status == 'Submitted' || status == 'Open') {
      statusColor = const Color(0xFF2563EB); // Blue
      statusIcon = Icons.send_outlined;
    } else if (status != 'Submitted' && status != 'Resolved') {
      // Any step in between (Received, Assigned, etc.)
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.pending_actions;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IssueDetailScreen(
              data: data,
              docId: doc.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: categoryBgColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: categoryColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr • $district',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4B5563),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        if (upvotes.contains(user.uid)) {
                          await FirebaseFirestore.instance
                              .collection('issues')
                              .doc(doc.id)
                              .update({
                                'upvotes': FieldValue.arrayRemove([user.uid]),
                              });
                        } else {
                          await FirebaseFirestore.instance
                              .collection('issues')
                              .doc(doc.id)
                              .update({
                                'upvotes': FieldValue.arrayUnion([user.uid]),
                              });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              upvotes.contains(
                                FirebaseAuth.instance.currentUser?.uid,
                              )
                              ? const Color(0xFFE0E7FF)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              size: 14,
                              color:
                                  upvotes.contains(
                                    FirebaseAuth.instance.currentUser?.uid,
                                  )
                                  ? const Color(0xFF4338CA)
                                  : const Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              likes.toString(),
                              style: TextStyle(
                                color:
                                    upvotes.contains(
                                      FirebaseAuth.instance.currentUser?.uid,
                                    )
                                    ? const Color(0xFF4338CA)
                                    : const Color(0xFF6B7280),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IssueDetailScreen(
                              data: data,
                              docId: doc.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: Color(0xFF4B5563),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$comments',
                              style: const TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (showAvatars)
                  Row(
                    children: [
                      _buildAvatarOverlap('https://i.pravatar.cc/100?img=1', 0),
                      _buildAvatarOverlap('https://i.pravatar.cc/100?img=2', 1),
                      _buildAvatarOverlapCount('+5', 2),
                    ],
                  )
                else
                  Row(
                    children: const [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOverlap(String url, int index) {
    return Transform.translate(
      offset: Offset(-index * 8.0, 0),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(url)),
      ),
    );
  }

  Widget _buildAvatarOverlapCount(String text, int index) {
    return Transform.translate(
      offset: Offset(-index * 8.0, 0),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFFE5E7EB),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          if (index == 1) {
            Navigator.pushNamed(context, '/my-reports');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/citizen-chats');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A4DDE),
        unselectedItemColor: const Color(0xFF9CA3AF),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'REPORTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'CHATS',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
  IconData _getCategoryIcon(String category) {
    category = category.toUpperCase();
    if (category.contains('INFRASTRUCTURE')) return Icons.construction;
    if (category.contains('HEALTH'))         return Icons.health_and_safety;
    if (category.contains('SECURITY'))       return Icons.security;
    if (category.contains('LAND'))           return Icons.landscape;
    if (category.contains('EDUCATION'))      return Icons.school;
    if (category.contains('JUSTICE'))        return Icons.gavel;
    if (category.contains('SOCIAL WELFARE')) return Icons.people;
    if (category.contains('UTILITIES'))      return Icons.lightbulb;
    return Icons.miscellaneous_services;
  }
}
