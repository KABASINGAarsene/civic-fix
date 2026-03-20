import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../state/citizen_home_provider.dart';
import '../shared/notifications_screen.dart';

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
              _MenuItem(
                Icons.assignment_outlined,
                'My Reports',
                '3 active',
                true,
                action: () =>
                    context.read<CitizenHomeProvider>().setNavIndex(2),
              ),
              _MenuItem(
                Icons.notifications_outlined,
                'Notifications',
                '2 unread',
                true,
                action: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const NotificationsScreen(isAdmin: false),
                  ),
                ),
              ),
              _MenuItem(
                Icons.bookmark_outline,
                'Saved Issues',
                '',
                false,
                action: () => _showComingSoon(context, 'Saved Issues'),
              ),
            ], context),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _MenuItem(
                Icons.person_outline,
                'Edit Profile',
                '',
                false,
                action: () => _showEditProfile(context),
              ),
              _MenuItem(
                Icons.lock_outline,
                'Change Password',
                '',
                false,
                action: () => _showChangePassword(context),
              ),
              _MenuItem(
                Icons.language,
                'Language',
                'English',
                false,
                action: () => _showLanguagePicker(context),
              ),
              _MenuItem(
                Icons.shield_outlined,
                'Privacy Settings',
                '',
                false,
                action: () => _showPrivacyInfo(context),
              ),
            ], context),
            const SizedBox(height: 16),
            _buildSection('Support', [
              _MenuItem(
                Icons.help_outline,
                'Help & FAQ',
                '',
                false,
                action: () => _showHelpFAQ(context),
              ),
              _MenuItem(
                Icons.feedback_outlined,
                'Send Feedback',
                '',
                false,
                action: () => _showFeedback(context),
              ),
              _MenuItem(
                Icons.info_outline,
                'About DistrictDirect',
                '',
                false,
                action: () => _showAbout(context),
              ),
            ], context),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Action Handlers ────────────────────────────────────────────────────────

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _EditProfileSheet(),
    );
  }

  void _showChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          _langOption(context, '🇷🇼', 'Kinyarwanda', 'KN'),
          _langOption(context, '🇬🇧', 'English', 'EN', selected: true),
          _langOption(context, '🇫🇷', 'Français', 'FR'),
        ],
      ),
    );
  }

  Widget _langOption(
    BuildContext context,
    String flag,
    String name,
    String code, {
    bool selected = false,
  }) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $name'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          if (selected)
            const Icon(Icons.check, color: AppColors.primaryBlue, size: 18),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Privacy Settings'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your data is protected under Rwanda\'s data privacy laws.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 12),
            Text('• Reports can be submitted anonymously',
                style: TextStyle(fontSize: 13)),
            Text('• Your phone number is never shared publicly',
                style: TextStyle(fontSize: 13)),
            Text('• Only assigned officers can view your contact',
                style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text(
              'Got it',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpFAQ(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Help & FAQ', style: AppTextStyles.h3),
              const SizedBox(height: 20),
              ..._faqItems.map(
                (faq) => _FAQTile(question: faq[0], answer: faq[1]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<List<String>> _faqItems = [
    [
      'How do I report an issue?',
      'Tap the "Report New Issue" button on the home screen. Fill in the category, description, and location, then submit.',
    ],
    [
      'How long does resolution take?',
      'Most issues are reviewed within 24–48 hours. Critical issues are prioritised and may be resolved faster.',
    ],
    [
      'Can I report anonymously?',
      'Yes! When submitting a report, toggle the "Report Anonymously" option. Your identity will be hidden from the public feed.',
    ],
    [
      'How do I track my report?',
      'Go to the "My Reports" tab. You\'ll see all your submissions and their current status.',
    ],
    [
      'What happens after I confirm a fix?',
      'The case is officially closed. Your confirmation is recorded and helps measure district performance.',
    ],
  ];

  void _showFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FeedbackSheet(),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'DistrictDirect',
      applicationVersion: 'v2.0.1',
      applicationIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.location_city,
          color: Colors.white,
          size: 28,
        ),
      ),
      children: const [
        Text(
          'DistrictDirect Rwanda is a government service portal that allows citizens to report local issues and track their resolution.',
        ),
        SizedBox(height: 8),
        Text('© 2024 Government of Rwanda. All rights reserved.'),
      ],
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

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
    return Container(width: 1, height: 36, color: AppColors.divider);
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
                    onTap: item.action,
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
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text(
                    'Are you sure you want to sign out of your account?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (r) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(widget.answer, style: AppTextStyles.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Edit Profile', style: AppTextStyles.h3),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Jean Amahoro',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: '+250 78 XXX XXXX',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'National ID (Optional)',
              hintText: 'Enter 16-digit NID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeedbackSheet extends StatelessWidget {
  const _FeedbackSheet();

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Send Feedback', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Help us improve DistrictDirect for your community.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts, suggestions, or report a problem...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback sent — thank you!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Submit Feedback',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String badge;
  final bool hasBadge;
  final VoidCallback? action;

  _MenuItem(
    this.icon,
    this.label,
    this.badge,
    this.hasBadge, {
    this.action,
  });
}
