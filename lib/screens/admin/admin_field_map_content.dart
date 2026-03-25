import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../shared/notifications_screen.dart';

class AdminFieldMapContent extends StatefulWidget {
  const AdminFieldMapContent({super.key});

  @override
  State<AdminFieldMapContent> createState() => _AdminFieldMapContentState();
}

class _AdminFieldMapContentState extends State<AdminFieldMapContent> {
  static const Color _darkHeader = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;

  // Currently selected marker index
  int _selectedMarker = 0;

  // Map controller for zoom and position
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  static const _markers = [
    _MapMarker(
      position: LatLng(-1.932, 30.040),
      color: Color(0xFF1E5EFF),
      icon: Icons.water_drop,
      label: 'Water Infrastructure Leak',
      priority: 'HIGH PRIORITY',
      distance: '2.4km from District Office',
    ),
    _MapMarker(
      position: LatLng(-1.920, 30.084),
      color: Color(0xFFFFC107),
      icon: Icons.bolt,
      label: 'Power Outage – Sector 3',
      priority: 'MEDIUM PRIORITY',
      distance: '4.1km from District Office',
    ),
    _MapMarker(
      position: LatLng(-1.956, 30.090),
      color: Color(0xFFDC3545),
      icon: Icons.warning_amber,
      label: 'Road Collapse – Main Road',
      priority: 'CRITICAL',
      distance: '1.8km from District Office',
    ),
    _MapMarker(
      position: LatLng(-1.966, 30.066),
      color: Color(0xFF28A745),
      icon: Icons.eco,
      label: 'Waste Dump Site',
      priority: 'LOW PRIORITY',
      distance: '5.3km from District Office',
    ),
    _MapMarker(
      position: LatLng(-1.926, 30.072),
      color: Color(0xFF9C27B0),
      icon: Icons.domain,
      label: 'Public Building Issue',
      priority: 'MEDIUM PRIORITY',
      distance: '3.0km from District Office',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIssue = _markers[_selectedMarker];
    return Stack(
      children: [
        // Full-screen mock map
        Positioned.fill(child: _buildMockMap()),

        // Header overlay (top)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _buildHeader(),
          ),
        ),

        // Search + filter bar
        Positioned(
          top: 76,
          left: 12,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: _buildSearchBar(),
          ),
        ),

        // Filter / layers buttons (top-right)
        Positioned(
          top: 130,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: _buildMapButtons(),
          ),
        ),

        // Zoom + location controls (right side, middle)
        Positioned(
          right: 12,
          bottom: 260,
          child: _buildZoomControls(),
        ),

        // Bottom issue card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomCard(selectedIssue),
        ),
      ],
    );
  }

  Widget _buildMockMap() {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(-1.9441, 30.0619), // Kigali center
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.civic_fix',
        ),
        MarkerLayer(
          markers: List.generate(_markers.length, (i) {
            final m = _markers[i];
            return Marker(
              point: m.position,
              width: _selectedMarker == i ? 44 : 38,
              height: _selectedMarker == i ? 44 : 38,
              child: GestureDetector(
                onTap: () => setState(() => _selectedMarker = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _selectedMarker == i ? 44 : 38,
                  height: _selectedMarker == i ? 44 : 38,
                  decoration: BoxDecoration(
                    color: m.color,
                    shape: BoxShape.circle,
                    border: _selectedMarker == i
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: m.color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(m.icon, color: Colors.white, size: 20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: _darkHeader.withOpacity(0.85),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.filter_list),
                        title: const Text('Filter by Priority'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Priority filter coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.layers_outlined),
                        title: const Text('Toggle Map Layers'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Map layers toggle coming soon'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.download_outlined),
                        title: const Text('Export Map Data'),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Exporting map data...'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Expanded(
            child: Text(
              'District Field Map',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(isAdmin: true),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _darkHeader.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white60, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search issues or locations',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
          ),
          const Icon(Icons.mic_none, color: Colors.white60, size: 20),
        ],
      ),
    );
  }

  Widget _buildMapButtons() {
    return Column(
      children: [
        _squareButton(Icons.tune, _blue),
        const SizedBox(height: 8),
        _squareButton(Icons.layers_outlined, _darkHeader),
      ],
    );
  }

  Widget _squareButton(IconData icon, Color bg) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            final currentZoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, currentZoom + 1);
          },
          child: _squareButton(Icons.add, _darkHeader),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            final currentZoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, currentZoom - 1);
          },
          child: _squareButton(Icons.remove, _darkHeader),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            _mapController.move(const LatLng(-1.9441, 30.0619), 13.0);
          },
          child: _squareButton(Icons.my_location, _darkHeader),
        ),
      ],
    );
  }

  Widget _buildBottomCard(_MapMarker issue) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: _darkHeader,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _textMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: issue.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          issue.priority,
                          style: TextStyle(
                            color: issue.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      issue.label,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Color(0xFF94A3B8), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          issue.distance,
                          style: AppTextStyles.caption
                              .copyWith(color: _textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Issue thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70,
                  height: 70,
                  color: issue.color.withOpacity(0.2),
                  child: Icon(issue.icon, color: issue.color, size: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Assigning to field officer...'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_alt_1,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Assign to Field Officer',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Getting directions to ${_markers[_selectedMarker].label}...'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions,
                      color: AppColors.textWhite, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data class for map markers
class _MapMarker {
  final LatLng position;
  final Color color;
  final IconData icon;
  final String label;
  final String priority;
  final String distance;

  const _MapMarker({
    required this.position,
    required this.color,
    required this.icon,
    required this.label,
    required this.priority,
    required this.distance,
  });
}
