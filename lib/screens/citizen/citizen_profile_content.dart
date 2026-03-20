import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CitizenProfileContent extends StatelessWidget {
  const CitizenProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundGrey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildSection('My Activity', [
              _MenuItem(Icons.assignment_outlined, 'My Reports', '3 active', true),
              _MenuItem(Icons.notifications_outlined, 'Notifications', '2 unread', true),
              _MenuItem(Icons.bookmark_outline, 'Saved Issues', '', false),
            ], context),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _MenuItem(Icons.person_outline, 'Edit Profile', '', false),
              _MenuItem(Icons.lock_outline, 'Change Password', '', false),
              _MenuItem(Icons.language, 'Language', 'English', false),
              _MenuItem(Icons.shield_outlined, 'Privacy Settings', '', false),
            ], context),
            const SizedBox(height: 16),
            _buildSection('Support', [
              _MenuItem(Icons.help_outline, 'Help & FAQ', '', false),
              _MenuItem(Icons.feedback_outlined, 'Send Feedback', '', false),
              _MenuItem(Icons.info_outline, 'About DistrictDirect', '', false),
            ], context),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.person, color: Colors.white, size: 44),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Jean Amahoro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Kirehe District, Rwanda',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Verified Citizen',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Row(
        children: [
          _stat('5', 'Reports\nSubmitted'),
          _divider(),
          _stat('3', 'Issues\nResolved'),
          _divider(),
          _stat('234', 'Total\nUpvotes'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider,
    );
  }

  Widget _buildSection(
      String title, List<_MenuItem> items, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.captionBold.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              final item = e.value;
              return Column(
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.vertical(
                      top: e.key == 0
                          ? const Radius.circular(14)
                          : Radius.zero,
                      bottom:
                          isLast ? const Radius.circular(14) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon,
                                color: AppColors.primaryBlue, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.badge.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.hasBadge
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.backgroundGrey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.badge,
                                style: AppTextStyles.badge.copyWith(
                                  color: item.hasBadge
                                      ? AppColors.error
                                      : AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.chevron_right,
                              color: AppColors.textTertiary, size: 18),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 56,
                        color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
          },
          icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
          label: const Text(
            'Sign Out',
            style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String badge;
  final bool hasBadge;

  const _MenuItem(this.icon, this.label, this.badge, this.hasBadge);
}
