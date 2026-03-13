import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';
import '../../state/admin_dashboard_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Admin dark palette
  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _green = AppColors.success;
  static const Color _blue = AppColors.primaryBlue;
  static const Color _red = AppColors.error;
  static const Color _orange = AppColors.warning;

  static const _tabs = ['Dashboard', 'Infrastructure', 'Health', 'Education'];

  @override
  void initState() {
    super.initState();
    // Load all dashboard data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _bg,
          bottomNavigationBar: _buildBottomNav(provider),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(),
                _buildCategoryTabs(provider),
                _buildStatGrid(provider),
                _buildSectionHeader('Priority Inbox', 'Sort by Urgency'),
                _buildPriorityInbox(provider),
                _buildSectionHeader('Monthly Performance', 'View All'),
                _buildBarChart(provider),
                _buildSectionHeader('District Hotspots', 'Open Map'),
                _buildHotspotCard(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.security,
                color: AppColors.textWhite,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ADMIN PORTAL',
                  style: AppTextStyles.captionBold.copyWith(
                    color: _blue,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'DistrictDirect Rwanda',
                  style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
                ),
              ],
            ),
            const Spacer(),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                  onPressed: () {}, // TODO: Open notifications
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: _card,
              child: const Icon(
                Icons.person,
                color: AppColors.textWhite,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Tabs

  Widget _buildCategoryTabs(AdminDashboardProvider provider) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _tabs.length,
          itemBuilder: (_, i) {
            final active = i == provider.selectedTab;
            return GestureDetector(
              onTap: () => provider.setTab(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? _blue : _card,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _tabs[i],
                  style: AppTextStyles.captionBold.copyWith(
                    color: active ? AppColors.textWhite : _textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // KPI Stats Grid

  Widget _buildStatGrid(AdminDashboardProvider provider) {
    if (provider.statsLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (provider.statsError != null) {
      return SliverToBoxAdapter(child: _buildErrorTile(provider.statsError!));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: provider.stats
            .map((stat) => _AdminStatCard(stat: stat, cardColor: _card))
            .toList(),
      ),
    );
  }

  // Section Header

  Widget _buildSectionHeader(String title, String action) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
            ),
            if (action.isNotEmpty)
              GestureDetector(
                onTap: () {}, // TODO: Handle section action
                child: Text(
                  action,
                  style: AppTextStyles.captionBold.copyWith(color: _blue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Priority Inbox

  Widget _buildPriorityInbox(AdminDashboardProvider provider) {
    if (provider.inboxLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (provider.inboxError != null) {
      return SliverToBoxAdapter(child: _buildErrorTile(provider.inboxError!));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _PriorityCard(
          issue: provider.inbox[i],
          onAssign: () => provider.assignIssue(provider.inbox[i].id),
          card: _card,
          blue: _blue,
          muted: _textMuted,
        ),
        childCount: provider.inbox.length,
      ),
    );
  }

  // Bar Chart

  Widget _buildBarChart(AdminDashboardProvider provider) {
    if (provider.chartLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

    if (provider.chartError != null) {
      return SliverToBoxAdapter(child: _buildErrorTile(provider.chartError!));
    }

    final data = provider.chartData;

    return SliverToBoxAdapter(
      child: Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(16, 20, 20, 16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legend
            Row(
              children: [
                _legendDot(_blue, 'Received'),
                const SizedBox(width: 16),
                _legendDot(_green, 'Resolved'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 140,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 40,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: TextStyle(color: _textMuted, fontSize: 9),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            data[i].month,
                            style: TextStyle(color: _textMuted, fontSize: 9),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: _textMuted.withOpacity(0.15),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].received.toDouble(),
                          color: _blue.withOpacity(0.7),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: data[i].resolved.toDouble(),
                          color: _green.withOpacity(0.85),
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption.copyWith(color: _textMuted)),
      ],
    );
  }

  // Hotspot Card

  Widget _buildHotspotCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: _red, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on, color: _red, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT HOTSPOT',
                    style: AppTextStyles.captionBold.copyWith(
                      color: _textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gasabo District',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '142 critical issues active',
                    style: AppTextStyles.caption.copyWith(color: _red),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  // Error tile helper

  Widget _buildErrorTile(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: _red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.caption.copyWith(color: _textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Navigation

  Widget _buildBottomNav(AdminDashboardProvider provider) {
    return BottomNavigationBar(
      currentIndex: provider.selectedNavIndex,
      onTap: provider.setNavIndex,
      backgroundColor: _card,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: _blue,
      unselectedItemColor: _textMuted,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_outlined),
          activeIcon: Icon(Icons.list_alt_rounded),
          label: 'Issues',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart_rounded),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

// Extracted stateless sub-widgets

/// KPI stat card for the 2×2 grid
class _AdminStatCard extends StatelessWidget {
  final AdminStat stat;
  final Color cardColor;

  const _AdminStatCard({required this.stat, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final trendColor = stat.trendUp == null
        ? const Color(0xFF94A3B8)
        : stat.trendUp!
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(stat.icon, color: stat.color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stat.trend,
                  style: AppTextStyles.badge.copyWith(color: trendColor),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            stat.label,
            style: AppTextStyles.badge.copyWith(
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.value,
            style: AppTextStyles.h2.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}

/// Priority inbox card
class _PriorityCard extends StatelessWidget {
  final PriorityIssue issue;
  final VoidCallback onAssign;
  final Color card, blue, muted;

  const _PriorityCard({
    required this.issue,
    required this.onAssign,
    required this.card,
    required this.blue,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: issue.tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(issue.icon, color: issue.tagColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        issue.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: issue.tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        issue.tag,
                        style: AppTextStyles.badge.copyWith(
                          color: issue.tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  issue.subtitle,
                  style: AppTextStyles.caption.copyWith(color: muted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, color: muted, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${issue.upvotes} upvotes',
                      style: AppTextStyles.caption.copyWith(color: muted),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onAssign,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text('Assign', style: AppTextStyles.buttonSmall),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
