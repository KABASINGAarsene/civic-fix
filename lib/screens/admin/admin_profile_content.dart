import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../shared/notifications_screen.dart';

class AdminProfileContent extends StatefulWidget {
  const AdminProfileContent({super.key});

  @override
  State<AdminProfileContent> createState() => _AdminProfileContentState();
}

class _AdminProfileContentState extends State<AdminProfileContent> {
  static const Color _bg = Color(0xFF0F172A);
  static const Color _card = Color(0xFF1E293B);
  static const Color _muted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;

  bool _notifReports = true;
  bool _notifAssignments = true;
  bool _notifAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 2),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildSection('Administration', [
              _MenuItem(Icons.dashboard_outlined, 'District Overview', '',
                  action: () => _showDistrictOverview(context)),
              _MenuItem(Icons.group_outlined, 'Manage Officers', '12 active',
                  action: () => _showOfficers(context)),
              _MenuItem(Icons.assignment_outlined, 'All Reports', '1,240 total',
                  action: () => _showSnack(context, 'Loading all 1,240 reports...')),
              _MenuItem(Icons.map_outlined, 'Field Assignments', '8 ongoing',
                  action: () => _showSnack(context, '8 active field assignments in progress')),
            ]),
            const SizedBox(height: 16),
            _buildSection('Account', [
              _MenuItem(Icons.person_outline, 'Edit Profile', '',
                  action: () => _showEditProfile(context)),
              _MenuItem(Icons.lock_outline, 'Change Password', '',
                  action: () => _showChangePassword(context)),
              _MenuItem(Icons.language, 'Language', 'English',
                  action: () => _showLanguagePicker(context)),
              _MenuItem(Icons.notifications_outlined, 'Notification Settings', '',
                  action: () => _showNotificationSettings(context)),
            ]),
            const SizedBox(height: 16),
            _buildSection('System', [
              _MenuItem(Icons.shield_outlined, 'Data & Privacy', '',
                  action: () => _showPrivacy(context)),
              _MenuItem(Icons.bar_chart_outlined, 'Export Reports', '',
                  action: () => _showSnack(context, 'Generating PDF report...')),
              _MenuItem(Icons.help_outline, 'Help & Support', '',
                  action: () => _showHelp(context)),
              _MenuItem(Icons.info_outline, 'About DistrictDirect', 'v2.0.1',
                  action: () => showAboutDialog(
                        context: context,
                        applicationName: 'DistrictDirect Rwanda',
                        applicationVersion: 'v2.0.1',
                        applicationLegalese: '© 2025 Kirehe District Office',
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            'A civic issue reporting and management platform connecting citizens with district administrators.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      )),
            ]),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showSnack(context, 'Profile photo upload coming soon'),
            child: Stack(
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

  Widget _buildSection(String title, List<_MenuItem> items) {
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
                    onTap: item.action,
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
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/', (r) => false),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
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

  // ── Action helpers ──────────────────────────────────────────────────────────

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showDistrictOverview(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('District Overview',
            style: TextStyle(color: AppColors.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _overviewRow('Total Issues', '1,240'),
            _overviewRow('Resolved', '1,104 (89%)'),
            _overviewRow('In Progress', '98'),
            _overviewRow('Pending', '38'),
            _overviewRow('Sectors', 'Kirehe, Gatore, Musaza, Nyamugari'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _overviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _muted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showOfficers(BuildContext context) {
    const officers = [
      ('Officer Mugabo Jean', 'Water & Sanitation', '3 active'),
      ('Officer Uwase Marie', 'Infrastructure', '2 active'),
      ('Officer Habimana Eric', 'Health', '1 active'),
      ('Officer Niyonzima Paul', 'Security', '2 active'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: _muted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Field Officers',
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...officers.map((o) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: _blue.withOpacity(0.15),
                  child: Icon(Icons.person, color: _blue, size: 18),
                ),
                title: Text(o.$1,
                    style: const TextStyle(
                        color: AppColors.textWhite, fontSize: 14)),
                subtitle: Text(o.$2,
                    style: TextStyle(color: _muted, fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(o.$3,
                      style: TextStyle(color: _blue, fontSize: 11)),
                ),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Mayor Jean Amahoro');
    final emailCtrl = TextEditingController(text: 'mayor@kirehe.gov.rw');
    final phoneCtrl = TextEditingController(text: '+250 788 000 001');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _muted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Edit Profile',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _darkField('Full Name', nameCtrl),
              const SizedBox(height: 14),
              _darkField('Email', emailCtrl),
              const SizedBox(height: 14),
              _darkField('Phone', phoneCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showSnack(context, 'Profile updated successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Change Password',
            style: TextStyle(color: AppColors.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _darkField('Current Password', currentCtrl, obscure: true),
            const SizedBox(height: 12),
            _darkField('New Password', newCtrl, obscure: true),
            const SizedBox(height: 12),
            _darkField('Confirm New Password', confirmCtrl, obscure: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: _muted))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnack(context, 'Password updated successfully');
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: _blue, elevation: 0),
            child: const Text('Update',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: _card,
        title: const Text('Select Language',
            style: TextStyle(color: AppColors.textWhite)),
        children: [
          _langOption(context, 'English', 'EN'),
          _langOption(context, 'Kinyarwanda', 'KN'),
          _langOption(context, 'Français', 'FR'),
        ],
      ),
    );
  }

  Widget _langOption(BuildContext context, String name, String code) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        _showSnack(context, 'Language set to $name');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(code,
                  style: TextStyle(
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Text(name,
                style: const TextStyle(
                    color: AppColors.textWhite, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _muted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Notification Settings',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _notifSwitch(
                ctx,
                setModalState,
                'New Reports',
                'Alert when citizens submit new reports',
                _notifReports,
                (v) => setState(() => _notifReports = v),
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              _notifSwitch(
                ctx,
                setModalState,
                'Field Assignments',
                'Alert when officers are assigned',
                _notifAssignments,
                (v) => setState(() => _notifAssignments = v),
              ),
              const Divider(color: Color(0xFF334155), height: 1),
              _notifSwitch(
                ctx,
                setModalState,
                'Critical Alerts',
                'High-priority issue escalations',
                _notifAlerts,
                (v) => setState(() => _notifAlerts = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notifSwitch(
    BuildContext ctx,
    StateSetter setModalState,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: (v) {
        setModalState(() {});
        onChanged(v);
      },
      title: Text(title,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
      subtitle: Text(subtitle,
          style: TextStyle(color: _muted, fontSize: 12)),
      activeThumbColor: _blue,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Data & Privacy',
            style: TextStyle(color: AppColors.textWhite)),
        content: Text(
          'DistrictDirect collects issue reports, location data, and communication logs to improve district services. Data is stored securely on government servers and never shared with third parties. You may request data deletion by contacting your district IT office.',
          style: TextStyle(color: _muted, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _muted.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              const Text('Help & Support',
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ...[
                ('How do I assign an officer?',
                    'Go to Issues → select a ticket → tap Assign Officer, then choose from the active officer list.'),
                ('How do I export reports?',
                    'Go to Settings → Export Reports. A PDF will be generated for the current month.'),
                ('How do I change issue status?',
                    'Open the ticket detail screen and use the Status dropdown to update it to Submitted, In Progress, or Resolved.'),
                ('Who do I contact for technical support?',
                    'Email support@districtdirect.rw or call the IT helpdesk at +250 788 000 999.'),
              ].map((item) => _HelpTile(
                    question: item.$1,
                    answer: item.$2,
                    muted: _muted,
                    blue: _blue,
                    card: _card,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _darkField(String label, TextEditingController ctrl,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _muted.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _muted.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _HelpTile extends StatefulWidget {
  final String question;
  final String answer;
  final Color muted;
  final Color blue;
  final Color card;

  const _HelpTile({
    required this.question,
    required this.answer,
    required this.muted,
    required this.blue,
    required this.card,
  });

  @override
  State<_HelpTile> createState() => _HelpTileState();
}

class _HelpTileState extends State<_HelpTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.question,
                        style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.muted,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(widget.answer,
                    style: TextStyle(
                        color: widget.muted, fontSize: 13, height: 1.5)),
              ],
            ],
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
  final VoidCallback? action;

  _MenuItem(this.icon, this.label, this.badge, {this.action});
}
