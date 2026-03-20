import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class AdminProfileContent extends StatelessWidget {
  const AdminProfileContent({super.key});

  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 2),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildSection('Administration', [
              _MenuItem(Icons.dashboard_outlined, 'District Overview', ''),
              _MenuItem(Icons.group_outlined, 'Manage Officers', '12 active'),
              _MenuItem(Icons.assignment_outlined, 'All Reports', '1,240 total'),
              _MenuItem(Icons.map_outlined, 'Field Assignments', '8 ongoing'),
            ], context),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _MenuItem(Icons.person_outline, 'Edit Profile', ''),
              _MenuItem(Icons.lock_outline, 'Change Password', ''),
              _MenuItem(Icons.language, 'Language', 'English'),
              _MenuItem(Icons.notifications_outlined, 'Notification Settings', ''),
            ], context),
            const SizedBox(height: 16),
            _buildSection('System', [
              _MenuItem(Icons.shield_outlined, 'Data & Privacy', ''),
              _MenuItem(Icons.bar_chart_outlined, 'Export Reports', ''),
              _MenuItem(Icons.help_outline, 'Help & Support', ''),
              _MenuItem(Icons.info_outline, 'About DistrictDirect', 'v2.0.1'),
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
      color: _card,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: _blue,
                child: const Icon(Icons.person, color: Colors.white, size: 44),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: _card, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Mayor Jean Amahoro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: _muted,
              ),
              const SizedBox(width: 4),
              Text(
                'Kirehe District Office',
                style: AppTextStyles.bodySmall.copyWith(color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badge('DISTRICT MAYOR', _blue),
              const SizedBox(width: 8),
              _badge('VERIFIED', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          _stat('1,240', 'Total\nManaged'),
          _divider(),
          _stat('89%', 'Resolution\nRate'),
          _divider(),
          _stat('4', 'Sectors\nCovered'),
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
              color: _blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: _muted),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider.withOpacity(0.3),
    );
  }

  Widget _buildSection(
    String title,
    List<_MenuItem> items,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.captionBold.copyWith(
              color: _muted,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(14),
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
                      bottom: isLast
                          ? const Radius.circular(14)
                          : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item.icon,
                              color: _blue,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                          if (item.badge.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _blue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.badge,
                                style: AppTextStyles.badge.copyWith(
                                  color: _blue,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            Icons.chevron_right,
                            color: _muted,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: 56,
                      color: AppColors.divider.withOpacity(0.15),
                    ),
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
              fontSize: 16,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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

  const _MenuItem(this.icon, this.label, this.badge);
}
