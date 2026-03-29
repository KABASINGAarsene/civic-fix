import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:district_direct/l10n/app_localizations.dart';

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: scheme.primary))
        : Stack(
        children: [
          // FlutterMap with real coordinates
          _buildFlutterMap(),

          // Territory Isolation Banner
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTerritoryBanner(),
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
          backgroundColor: scheme.surface,
          child: Icon(Icons.layers, color: scheme.onSurface),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.togglingHeatmapLayer)),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: Text(
        l10n.districtFieldMapTitle,
        style: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: scheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFlutterMap() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issues')
          .where('district', isEqualTo: _adminDistrict)
          .snapshots(),
      builder: (context, snapshot) {
        List<Marker> markers = [];
        
        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          int markerCount = 0;
          for (var entry in docs) {
            final data = entry.data() as Map<String, dynamic>;
            final lat = data['latitude'] as double?;
            final lng = data['longitude'] as double?;
            
            if (lat != null && lng != null) {
              markers.add(
                Marker(
                  point: LatLng(lat, lng),
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/admin-ticket-detail',
                        arguments: {
                          'data': data,
                          'ticketId': entry.id,
                        },
                      );
                    },
                    child: _buildMapPin(
                      markerCount + 1 > 9 ? "!" : (markerCount + 1).toString(),
                      _getPriorityColor(data['priority']),
                    ),
                  ),
                ),
              );
              markerCount++;
            }
          }
        }

        // Default center for Rwanda
        const LatLng kigaliCenter = LatLng(-1.9536, 29.8739);

        return FlutterMap(
          options: const MapOptions(
            initialCenter: kigaliCenter,
            initialZoom: 9.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'civic.fix',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  Widget _buildTerritoryBanner() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withOpacity(0.5)),
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
              color: scheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.security, color: scheme.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exclusiveTerritoryView,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.viewingIssuesAssignedTo} ${_adminDistrict ?? l10n.unknownDistrict}',
                  style: TextStyle(
                    color: scheme.onSurface,
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
    final scheme = Theme.of(context).colorScheme;
    if (priority is num) {
      if (priority >= 2) return const Color(0xFFEF4444); // Critical
      if (priority >= 1) return const Color(0xFFF59E0B); // Medium
      return const Color(0xFF10B981); // Low
    }
    return scheme.primary;
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
            color: scheme.surface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withOpacity(0.45)),
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
                  Text(
                    l10n.activeFieldTeams,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$fieldVisits ${l10n.activeVisits}',
                    style: TextStyle(
                      color: _statusSemanticColor('Field Visit', scheme),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
                _buildTeamRow(
                  l10n.fieldSupportTeams,
                  '$fieldVisits ${l10n.activeVisits} ${_adminDistrict ?? ''}',
                  _statusSemanticColor('Field Visit', scheme),
                ),
              const SizedBox(height: 12),
                _buildTeamRow(
                  l10n.resolvedIssues,
                  '$resolved ${l10n.closedToday}',
                  _statusSemanticColor('Resolved', scheme),
                ),
            ],
          ),
        );
      }
    );
  }

    Widget _buildTeamRow(String name, String location, Color statusColor) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          location,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
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
