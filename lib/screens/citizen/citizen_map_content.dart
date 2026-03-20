import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CitizenMapContent extends StatefulWidget {
  const CitizenMapContent({super.key});

  @override
  State<CitizenMapContent> createState() => _CitizenMapContentState();
}

class _CitizenMapContentState extends State<CitizenMapContent> {
  int _selectedIssue = 0;

  static const _issues = [
    _IssuePin(
      top: 0.38, left: 0.30,
      color: Color(0xFF1E5EFF),
      icon: Icons.water_drop,
      title: 'Water Leak – Kirehe Main St.',
      category: 'INFRASTRUCTURE',
      status: 'IN PROGRESS',
      statusColor: Color(0xFFFFC107),
      timeLocation: '2h ago • Central Market',
    ),
    _IssuePin(
      top: 0.25, left: 0.56,
      color: Color(0xFFFFC107),
      icon: Icons.bolt,
      title: 'Street Light Failure – Sector 4',
      category: 'UTILITIES',
      status: 'IN PROGRESS',
      statusColor: Color(0xFFFFC107),
      timeLocation: '5h ago • Primary School Zone',
    ),
    _IssuePin(
      top: 0.55, left: 0.62,
      color: Color(0xFF28A745),
      icon: Icons.delete_outline,
      title: 'New Waste Collection Point',
      category: 'ENVIRONMENT',
      status: 'REPORTED',
      statusColor: Color(0xFF17A2B8),
      timeLocation: 'Yesterday • Gaisaka Center',
    ),
    _IssuePin(
      top: 0.48, left: 0.45,
      color: Color(0xFFDC3545),
      icon: Icons.edit_road,
      title: 'Pothole on KG 11 Ave',
      category: 'ROADS',
      status: 'RESOLVED',
      statusColor: Color(0xFF28A745),
      timeLocation: '3d ago • Gasabo District',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map background
        Positioned.fill(child: _buildMockMap()),

        // Search bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: _buildSearchBar(),
          ),
        ),

        // Filter chips
        Positioned(
          top: 68,
          left: 12,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: _buildFilterChips(),
          ),
        ),

        // Zoom controls
        Positioned(
          right: 12,
          bottom: 200,
          child: _buildZoomControls(),
        ),

        // Bottom card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomCard(_issues[_selectedIssue]),
        ),
      ],
    );
  }

  Widget _buildMockMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Container(
          color: const Color(0xFFE4F0E8),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(w, h),
                painter: _CitizenMapPainter(),
              ),
              // Labels
              _label('NGIRYI', w * 0.56, h * 0.05),
              _label('KABUYE', w * 0.20, h * 0.18),
              _label('GASANZE', w * 0.62, h * 0.15),
              _label('KAGUGU', w * 0.59, h * 0.30),
              _label('KIGALI', w * 0.42, h * 0.48),
              _label('KIYOVU', w * 0.40, h * 0.60),
              _label('GACURIRO', w * 0.68, h * 0.33),
              // Issue markers
              ...List.generate(_issues.length, (i) {
                final pin = _issues[i];
                return Positioned(
                  top: h * pin.top - 22,
                  left: w * pin.left - 22,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedIssue = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _selectedIssue == i ? 46 : 38,
                      height: _selectedIssue == i ? 46 : 38,
                      decoration: BoxDecoration(
                        color: pin.color,
                        shape: BoxShape.circle,
                        border: _selectedIssue == i
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: pin.color.withOpacity(0.45),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(pin.icon, color: Colors.white, size: 20),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text, double x, double y) {
    return Positioned(
      left: x,
      top: y,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A5568),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search issues near you...',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
          ),
          const Icon(Icons.mic_none, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['All', 'Infrastructure', 'Utilities', 'Environment'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.asMap().entries.map((e) {
          final active = e.key == 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryBlue : AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              e.value,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        _zoomBtn(Icons.add),
        const SizedBox(height: 8),
        _zoomBtn(Icons.remove),
        const SizedBox(height: 8),
        _zoomBtn(Icons.my_location),
      ],
    );
  }

  Widget _zoomBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 20),
    );
  }

  Widget _buildBottomCard(_IssuePin pin) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(pin.category,
                    style: AppTextStyles.badge
                        .copyWith(color: AppColors.primaryBlue, fontSize: 10)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: pin.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(pin.status,
                    style: AppTextStyles.badge.copyWith(
                        color: pin.statusColor, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(pin.title, style: AppTextStyles.h4.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 12, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(pin.timeLocation, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_alt_outlined,
                      color: Colors.white, size: 16),
                  label: const Text('Upvote',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssuePin {
  final double top;
  final double left;
  final Color color;
  final IconData icon;
  final String title;
  final String category;
  final String status;
  final Color statusColor;
  final String timeLocation;

  const _IssuePin({
    required this.top,
    required this.left,
    required this.color,
    required this.icon,
    required this.title,
    required this.category,
    required this.status,
    required this.statusColor,
    required this.timeLocation,
  });
}

class _CitizenMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withOpacity(0.65)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final minor = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.50), Offset(size.width, size.height * 0.50),
        road);
    canvas.drawLine(
        Offset(size.width * 0.45, 0), Offset(size.width * 0.45, size.height),
        road);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.1),
        Offset(size.width * 0.50, size.height * 0.50), minor);
    canvas.drawLine(Offset(size.width * 0.45, size.height * 0.30),
        Offset(size.width * 0.80, size.height * 0.15), minor);
    canvas.drawLine(Offset(size.width * 0.45, size.height * 0.50),
        Offset(size.width * 0.80, size.height * 0.70), minor);
    canvas.drawLine(Offset(size.width * 0.10, size.height * 0.50),
        Offset(size.width * 0.28, size.height * 0.80), minor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
