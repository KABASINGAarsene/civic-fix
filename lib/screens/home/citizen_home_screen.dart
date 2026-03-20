import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';
import '../../state/citizen_home_provider.dart';
import './citizen_reports_details.dart';
import '../report_issue_screen.dart';
import '../citizen/citizen_map_content.dart';
import '../citizen/citizen_profile_content.dart';
import '../shared/notifications_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  static const _filters = ['Kirehe District', 'Sector', 'Cell'];

  @override
  void initState() {
    super.initState();
    // Load feed after first frame so the provider is fully attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitizenHomeProvider>().loadFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitizenHomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundGrey,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildTabContent(provider)),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(provider),
        );
      },
    );
  }

  // Header

  Widget _buildHeader() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryBlue,
            radius: 20,
            child: Icon(Icons.person, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MURAHO, JEAN', style: AppTextStyles.captionBold),
              Text('DistrictDirect', style: AppTextStyles.h3),
            ],
          ),
          const Spacer(),
          // Notification bell with unread dot
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const NotificationsScreen(isAdmin: false),
                      ),
                    );
                  }
              ),
              Positioned(
                right: 8,
                top: 8,
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

  // Report Button

  Widget _buildReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
          );
        },
        icon: const Icon(Icons.add_circle_outline, color: AppColors.textWhite),
        label: Text('REPORT NEW ISSUE', style: AppTextStyles.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          elevation: 2,
          shadowColor: AppColors.primaryBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // Filter Chips

  Widget _buildFilterRow(CitizenHomeProvider provider) {
    return Row(
      children: List.generate(_filters.length, (i) {
        final active = i == provider.selectedFilterIndex;
        return Expanded(
          flex: i == 0 ? 2 : 1,
          child: GestureDetector(
            onTap: () => provider.setFilterIndex(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primaryBlue
                    : AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(20),
                border: active
                    ? null
                    : Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    i == 0
                        ? Icons.location_on_outlined
                        : i == 1
                        ? Icons.domain_outlined
                        : Icons.grid_view_outlined,
                    size: 14,
                    color: active
                        ? AppColors.textWhite
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _filters[i],
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: active
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Feed Header

  Widget _buildFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('District Feed', style: AppTextStyles.h3),
        TextButton.icon(
          onPressed: () =>
              context.read<CitizenHomeProvider>().setNavIndex(1),
          icon: const Icon(
            Icons.map_outlined,
            size: 16,
            color: AppColors.primaryBlue,
          ),
          label: Text(
            'View Map',
            style: AppTextStyles.link.copyWith(decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContent(CitizenHomeProvider provider) {
    switch (provider.selectedNavIndex) {
      case 0:
        return _buildHomeTabContent(provider);
      case 2:
        return _buildMyReportsTabContent(provider);
      case 1:
        return const CitizenMapContent();
      case 3:
        return const CitizenProfileContent();
      default:
        return _buildHomeTabContent(provider);
    }
  }

  Widget _buildHomeTabContent(CitizenHomeProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        _buildReportButton(),
        const SizedBox(height: 20),
        _buildFilterRow(provider),
        const SizedBox(height: 24),
        _buildFeedHeader(),
        const SizedBox(height: 12),
        _buildFeedBody(provider),
      ],
    );
  }

  Widget _buildMyReportsTabContent(CitizenHomeProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton.extended(
            heroTag: 'myReportsFab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportIssueScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('REPORT NEW ISSUE'),
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 18),
        Text('My Reports', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        _buildMyReportsBody(provider),
      ],
    );
  }

  Widget _buildMyReportsBody(CitizenHomeProvider provider) {
    if (provider.myReportedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Text(
          'You have not submitted any issue yet.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: provider.myReportedItems
          .map(
            (item) => InkWell(
              onTap: () => _navigateToDetails(item),
              child: _buildFeedCard(
                item,
                showUpdateAction: item.status == ReportStatus.submitted,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(title, style: AppTextStyles.h4),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feed Body: loading / error / data

  Widget _buildFeedBody(CitizenHomeProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: provider.loadFeed,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.feedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No reports yet in your area.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: provider.feedItems
          .map(
            (item) => InkWell(
              onTap: () => _navigateToDetails(item),
              child: _buildFeedCard(item),
            ),
          )
          .toList(),
    );
  }

  // Navigation Helper
  void _navigateToDetails(ReportItem item) {
    // Simulate an assigned officer for in-progress reports
    final assignedTo = item.status == ReportStatus.inProgress
        ? 'Officer Jean Pierre'
        : null;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          report: ReportDetailData.fromReportItem(
            item,
            location: item.address.isNotEmpty ? item.address : item.timeLocation,
            submittedDate: '2 days ago',
            lastUpdate: '1 hour ago',
            assignedTo: assignedTo,
          ),
        ),
      ),
    );
  }

  // Feed Card

  Widget _buildFeedCard(ReportItem item, {bool showUpdateAction = false}) {
    final statusColor = item.status == ReportStatus.resolved
        ? AppColors.success
        : item.status == ReportStatus.inProgress
        ? AppColors.warning
        : item.status == ReportStatus.submitted
        ? AppColors.info
        : AppColors.info;

    final statusLabel = item.status == ReportStatus.resolved
        ? 'RESOLVED'
        : item.status == ReportStatus.inProgress
        ? 'IN PROGRESS'
        : item.status == ReportStatus.submitted
        ? 'SUBMITTED'
        : 'REPORTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.category,
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.8,
                          ),
                        ),
                        _buildStatusBadge(statusLabel, statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.title, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(item.timeLocation, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionChip(Icons.thumb_up_outlined, item.likes.toString()),
              const SizedBox(width: 10),
              _buildActionChip(
                Icons.chat_bubble_outline,
                item.comments.toString(),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => _navigateToDetails(item),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Details',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              if (showUpdateAction) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportIssueScreen(editingIssue: item),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tealDark,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    'Update',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.tealDark,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 5),
          Text(
            count,
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation

  Widget _buildBottomNav(CitizenHomeProvider provider) {
    return BottomNavigationBar(
      currentIndex: provider.selectedNavIndex,
      onTap: provider.setNavIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.backgroundWhite,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textTertiary,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      elevation: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'HOME',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'MAP',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'My reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'PROFILE',
        ),
      ],
    );
  }
}
