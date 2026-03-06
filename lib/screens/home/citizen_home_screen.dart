import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

/// Citizen Home Screen
/// Personal dashboard showing user's own reports and status tracking

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({Key? key}) : super(key: key);

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _selectedNavIndex = 0;

  // Mock data — replace with real API data
  final String _userName = 'Amahoro';
  final List<_ReportItem> _reports = [
    _ReportItem(
      id: 'DD-2024-0041',
      title: 'Broken Pipe on Main Street',
      category: 'Water',
      categoryIcon: Icons.water_drop_outlined,
      status: ReportStatus.inProgress,
      submittedDate: 'Feb 28, 2024',
      lastUpdate: '2 hours ago',
    ),
    _ReportItem(
      id: 'DD-2024-0038',
      title: 'Street Light Failure – Sector 4',
      category: 'Electricity',
      categoryIcon: Icons.lightbulb_outline,
      status: ReportStatus.inReview,
      submittedDate: 'Feb 25, 2024',
      lastUpdate: '1 day ago',
    ),
    _ReportItem(
      id: 'DD-2024-0031',
      title: 'Pothole Near Primary School',
      category: 'Roads',
      categoryIcon: Icons.add_road_outlined,
      status: ReportStatus.resolved,
      submittedDate: 'Feb 10, 2024',
      lastUpdate: '5 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildGreetingBanner(),
                    const SizedBox(height: 28),
                    _buildReportButton(),
                    const SizedBox(height: 32),
                    _buildSectionHeader(),
                    const SizedBox(height: 16),
                    if (_reports.isEmpty)
                      _buildEmptyState()
                    else
                      ..._reports.map((r) => _buildReportCard(r)).toList(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          // App name
          Text(
            'DistrictDirect',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primaryBlue,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
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

  // ─── Greeting Banner ───────────────────────────────────────────────────────

  Widget _buildGreetingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Muraho, $_userName 👋', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  'You have ${_reports.where((r) => r.status != ReportStatus.resolved).length} active reports',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Summary pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_reports.length} Total',
              style: AppTextStyles.buttonSmall.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Report Button ─────────────────────────────────────────────────────────

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Navigate to report issue flow
        },
        icon: const Icon(Icons.add, color: AppColors.textWhite, size: 22),
        label: Text('Report a New Issue', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Text('My Reports', style: AppTextStyles.h4),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to full reports list
          },
          child: Text('View all', style: AppTextStyles.link),
        ),
      ],
    );
  }

  // ─── Report Card ───────────────────────────────────────────────────────────

  Widget _buildReportCard(_ReportItem report) {
    final statusConfig = _statusConfig(report.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to report detail screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: category + status badge
              Row(
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          report.categoryIcon,
                          size: 13,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          report.category,
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusConfig.dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusConfig.label,
                          style: AppTextStyles.badge.copyWith(
                            color: statusConfig.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                report.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              // Tracking ID
              Text(
                'Tracking ID: ${report.id}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              // Divider
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 12),
              // Bottom row: submitted date + last update
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 5),
                  Text(report.submittedDate, style: AppTextStyles.caption),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Updated ${report.lastUpdate}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No reports yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the button above to report your first issue.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const items = [
      _NavItem(Icons.home_outlined, Icons.home, 'Home'),
      _NavItem(Icons.list_alt_outlined, Icons.list_alt, 'My Reports'),
      _NavItem(Icons.add_circle_outline, Icons.add_circle, 'Report'),
      _NavItem(Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = _selectedNavIndex == i;
              // Make centre "Report" button accent
              final isReport = i == 2;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedNavIndex = i);
                    // TODO: Handle navigation
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: isReport ? 30 : 24,
                        color: isReport
                            ? AppColors.primaryBlue
                            : isSelected
                            ? AppColors.primaryBlue
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.badge.copyWith(
                          color: isReport
                              ? AppColors.primaryBlue
                              : isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textTertiary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Status Config Helper ──────────────────────────────────────────────────

  _StatusConfig _statusConfig(ReportStatus status) {
    switch (status) {
      case ReportStatus.submitted:
        return _StatusConfig(
          label: 'Submitted',
          bgColor: AppColors.info.withOpacity(0.1),
          dotColor: AppColors.info,
          textColor: AppColors.info,
        );
      case ReportStatus.inReview:
        return _StatusConfig(
          label: 'In Review',
          bgColor: AppColors.warning.withOpacity(0.12),
          dotColor: AppColors.warning,
          textColor: const Color(0xFF996600),
        );
      case ReportStatus.inProgress:
        return _StatusConfig(
          label: 'In Progress',
          bgColor: AppColors.primaryBlue.withOpacity(0.08),
          dotColor: AppColors.primaryBlue,
          textColor: AppColors.primaryBlue,
        );
      case ReportStatus.resolved:
        return _StatusConfig(
          label: 'Resolved',
          bgColor: AppColors.success.withOpacity(0.1),
          dotColor: AppColors.success,
          textColor: AppColors.success,
        );
    }
  }
}

// ─── Supporting Types ─────────────────────────────────────────────────────────

enum ReportStatus { submitted, inReview, inProgress, resolved }

class _ReportItem {
  final String id;
  final String title;
  final String category;
  final IconData categoryIcon;
  final ReportStatus status;
  final String submittedDate;
  final String lastUpdate;

  const _ReportItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryIcon,
    required this.status,
    required this.submittedDate,
    required this.lastUpdate,
  });
}

class _StatusConfig {
  final String label;
  final Color bgColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.bgColor,
    required this.dotColor,
    required this.textColor,
  });
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
