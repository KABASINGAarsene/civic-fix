import 'package:flutter/material.dart';
import 'package:district_direct/l10n/app_localizations.dart';
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

  Color _statusAccentColor(String status, ColorScheme scheme) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'resolved') {
      return scheme.tertiary;
    }
    if (normalized == 'submitted' || normalized == 'open') {
      return scheme.primary;
    }
    if (normalized == 'received' ||
        normalized == 'assigned' ||
        normalized == 'field visit' ||
        normalized == 'in progress') {
      return const Color(0xFFF59E0B);
    }
    return scheme.onSurfaceVariant;
  }

  IconData _statusIcon(String status) {
    final normalized = status.trim().toLowerCase();
    if (normalized == 'resolved') return Icons.check_circle;
    if (normalized == 'submitted' || normalized == 'open') {
      return Icons.send_outlined;
    }
    if (normalized == 'received' ||
        normalized == 'assigned' ||
        normalized == 'field visit' ||
        normalized == 'in progress') {
      return Icons.pending_actions;
    }
    return Icons.info;
  }

  Color _statusChipBackground(
    String status,
    ColorScheme scheme,
    Brightness brightness,
  ) {
    final accent = _statusAccentColor(status, scheme);
    final alpha = brightness == Brightness.dark ? 0.22 : 0.12;
    return accent.withValues(alpha: alpha);
  }

  Color _statusIconBackground(
    String status,
    ColorScheme scheme,
    Brightness brightness,
  ) {
    final accent = _statusAccentColor(status, scheme);
    final alpha = brightness == Brightness.dark ? 0.16 : 0.08;
    return accent.withValues(alpha: alpha);
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60.0),
                        child: Text(
                          l10n.homeNoDistrictReports,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.surface,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: scheme.onPrimary, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AMAHORO, JEAN',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'DistrictDirect',
            style: TextStyle(
              color: scheme.onSurface,
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
                color: scheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
              ),
              child: Icon(
                Icons.notifications_none,
                color: scheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            Positioned(
              right: 20,
              top: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.tertiary,
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.3),
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
            children: [
              Icon(Icons.add, color: scheme.onPrimary),
              SizedBox(width: 8),
              Text(
                l10n.homeReportNewIssue,
                style: TextStyle(
                  color: scheme.onPrimary,
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
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Province Filter
          _buildDropdownFilter(
            label: _selectedProvince ?? l10n.homeProvince,
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
            label: _selectedDistrict ?? l10n.homeDistrict,
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
            label: _selectedSector ?? l10n.homeSector,
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
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
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
            color: isActive
                ? scheme.primary
                : (isLight ? const Color(0xFFF3F4F6) : scheme.surface),
            borderRadius: BorderRadius.circular(20),
            border: isActive
                ? null
                : Border.all(color: scheme.outline.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? scheme.onPrimary
                    : (isDisabled
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.65)
                        : (isLight ? const Color(0xFF4B5563) : scheme.onSurfaceVariant)),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? scheme.onPrimary
                      : (isDisabled
                          ? scheme.onSurfaceVariant.withValues(alpha: 0.65)
                          : (isLight ? const Color(0xFF4B5563) : scheme.onSurfaceVariant)),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 14, color: scheme.onPrimary),
                ),
              ] else if (!isDisabled) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: isLight ? const Color(0xFF4B5563) : scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFeedHeader() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.homeDistrictFeed,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(Icons.map, size: 16, color: scheme.primary),
              SizedBox(width: 6),
              Text(
                l10n.homeViewMap,
                style: TextStyle(
                  color: scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
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
    final Color statusColor = _statusAccentColor(status, scheme);
    final Color categoryBgColor = _statusChipBackground(status, scheme, brightness);
    final Color iconBgColor = _statusIconBackground(status, scheme, brightness);
    final Color categoryColor = statusColor;
    IconData iconData = _getCategoryIcon(category);
    final IconData statusIcon = _statusIcon(status);

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
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.15),
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
                    color: iconBgColor,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr • $district',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
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
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
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
                              ? scheme.primary.withValues(alpha: 0.14)
                              : scheme.surfaceContainerHighest,
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
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              likes.toString(),
                              style: TextStyle(
                                color:
                                    upvotes.contains(
                                      FirebaseAuth.instance.currentUser?.uid,
                                    )
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
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
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$comments',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
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
                    children: [
                      Text(
                        AppLocalizations.of(context)!.homeDetails,
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: scheme.primary,
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
    final scheme = Theme.of(context).colorScheme;

    return Transform.translate(
      offset: Offset(-index * 8.0, 0),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(radius: 12, backgroundImage: NetworkImage(url)),
      ),
    );
  }

  Widget _buildAvatarOverlapCount(String text, int index) {
    final scheme = Theme.of(context).colorScheme;

    return Transform.translate(
      offset: Offset(-index * 8.0, 0),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: scheme.surfaceContainerHighest,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        ),
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
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.homeLabel),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long),
            label: l10n.reportsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            label: l10n.chatsLabel,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.profileLabel),
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
