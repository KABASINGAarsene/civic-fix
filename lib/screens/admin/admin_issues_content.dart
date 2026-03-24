import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';
import '../../state/admin_dashboard_provider.dart';
import 'admin_ticket_detail_screen.dart';

class AdminIssuesContent extends StatefulWidget {
  const AdminIssuesContent({super.key});

  @override
  State<AdminIssuesContent> createState() => _AdminIssuesContentState();
}

class _AdminIssuesContentState extends State<AdminIssuesContent>
    with SingleTickerProviderStateMixin {
  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;

  static const _categories = ['All', 'Infrastructure', 'Health', 'Water'];
  int _categoryIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AdminIssue> _filtered(List<AdminIssue> all, String status) {
    return all.where((i) {
      final categoryMatch = _categoryIndex == 0 ||
          i.category.toLowerCase() ==
              _categories[_categoryIndex].toLowerCase();
      return i.status == status && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardProvider>(
      builder: (context, provider, _) {
        return Container(
          color: _bg,
          child: Column(
            children: [
              _buildHeader(context),
              _buildCategoryChips(),
              _buildTabBar(),
              Expanded(
                child: provider.issuesLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildIssueList(
                              context, _filtered(provider.allIssues, 'submitted')),
                          _buildIssueList(
                              context, _filtered(provider.allIssues, 'inProgress')),
                          _buildIssueList(
                              context, _filtered(provider.allIssues, 'resolved')),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textWhite, size: 24),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: _card,
                shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                                color: _textMuted.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(2))),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        autofocus: true,
                        style: const TextStyle(
                            color: AppColors.textWhite, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search issues, locations, or ticket IDs...',
                          hintStyle:
                              TextStyle(color: _textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.search,
                              color: _textMuted, size: 20),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (query) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  query.isEmpty
                                      ? 'Enter a search term'
                                      : 'Searching for "$query"...'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          const Expanded(
            child: Text(
              'Issues Management',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textWhite,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: _card,
            child: const Icon(Icons.person, color: AppColors.textWhite, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final active = i == _categoryIndex;
          return GestureDetector(
            onTap: () => setState(() => _categoryIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _blue : _card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _categories[i],
                style: AppTextStyles.captionBold.copyWith(
                  color: active ? AppColors.textWhite : _textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _card, width: 2),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: _blue,
        indicatorWeight: 2,
        labelColor: _blue,
        unselectedLabelColor: _textMuted,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: const [
          Tab(text: 'Submitted'),
          Tab(text: 'In Progress'),
          Tab(text: 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildIssueList(BuildContext context, List<AdminIssue> issues) {
    if (issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: _textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              'No issues found',
              style: AppTextStyles.bodyMedium.copyWith(color: _textMuted),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: issues.length,
      itemBuilder: (_, i) => _buildIssueCard(context, issues[i]),
    );
  }

  Widget _buildIssueCard(BuildContext context, AdminIssue issue) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminTicketDetailScreen(issue: issue),
          ),
        );

        if (!mounted) {
          return;
        }

        await context.read<AdminDashboardProvider>().loadAll();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              child: Container(
                width: 90,
                height: 90,
                color: _thumbnailColor(issue.category),
                child: Icon(
                  _thumbnailIcon(issue.category),
                  color: Colors.white.withOpacity(0.85),
                  size: 38,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: issue.priorityColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            issue.priorityLabel,
                            style: AppTextStyles.badge.copyWith(
                              color: issue.priorityColor,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          issue.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: _textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Priority Score: ${issue.priorityScore}/100',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: _textMuted, size: 20),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.location,
                      style: AppTextStyles.caption.copyWith(
                        color: _textMuted,
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

  Color _thumbnailColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return const Color(0xFF28A745);
      case 'water':
        return const Color(0xFF17A2B8);
      case 'security':
        return const Color(0xFFDC3545);
      default:
        return const Color(0xFF3A5BA0);
    }
  }

  IconData _thumbnailIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.local_hospital_outlined;
      case 'water':
        return Icons.water_drop_outlined;
      case 'security':
        return Icons.security;
      default:
        return Icons.construction;
    }
  }
}
