import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isAdmin;

  const NotificationsScreen({super.key, this.isAdmin = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _adminBg = Color(0xFF0F172A);
  static const Color _adminCard = Color(0xFF1E293B);

  late List<_Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = widget.isAdmin ? _adminNotifications() : _citizenNotifications();
  }

  List<_Notification> _citizenNotifications() => [
        _Notification(
          id: '1',
          icon: Icons.build_outlined,
          color: AppColors.primaryBlue,
          title: 'Report In Progress',
          body: 'Your report "Broken Pipe in Kirehe Main St." has been assigned to Officer Jean Pierre.',
          time: '2h ago',
          isRead: false,
          tag: 'STATUS UPDATE',
        ),
        _Notification(
          id: '2',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
          title: 'Issue Resolved',
          body: 'Street Light Failure – Sector 4 has been resolved. Please confirm if it meets your satisfaction.',
          time: '5h ago',
          isRead: false,
          tag: 'RESOLVED',
        ),
        _Notification(
          id: '3',
          icon: Icons.thumb_up_alt_outlined,
          color: AppColors.warning,
          title: '45 Citizens Upvoted',
          body: 'Your report "New Waste Collection Point" has received 45 upvotes and is now high priority.',
          time: 'Yesterday',
          isRead: true,
          tag: 'COMMUNITY',
        ),
        _Notification(
          id: '4',
          icon: Icons.person_outline,
          color: AppColors.info,
          title: 'Officer Assigned',
          body: 'Officer Marie Claire has been assigned to your "Road Damage on KG 5 Ave" report.',
          time: '2 days ago',
          isRead: true,
          tag: 'ASSIGNMENT',
        ),
        _Notification(
          id: '5',
          icon: Icons.chat_outlined,
          color: AppColors.primaryBlue,
          title: 'New Message from Officer',
          body: 'Officer Jean Pierre: "We have dispatched a field team to inspect the issue. ETA 30 minutes."',
          time: '3 days ago',
          isRead: true,
          tag: 'MESSAGE',
        ),
      ];

  List<_Notification> _adminNotifications() => [
        _Notification(
          id: '1',
          icon: Icons.warning_amber_outlined,
          color: AppColors.error,
          title: 'Critical Issue Reported',
          body: 'A CRITICAL water infrastructure leak has been reported in Sector 4. Immediate action required.',
          time: '30 min ago',
          isRead: false,
          tag: 'CRITICAL',
        ),
        _Notification(
          id: '2',
          icon: Icons.assignment_turned_in_outlined,
          color: AppColors.success,
          title: 'Issue #DD-2045 Resolved',
          body: 'Officer Jean Pierre has marked Water Leak – Kirehe Main St. as resolved. Awaiting citizen confirmation.',
          time: '1h ago',
          isRead: false,
          tag: 'RESOLVED',
        ),
        _Notification(
          id: '3',
          icon: Icons.bar_chart_outlined,
          color: AppColors.primaryBlue,
          title: 'Weekly Report Ready',
          body: 'Your district\'s weekly performance report is ready. Resolution rate improved by +12.4%.',
          time: '3h ago',
          isRead: false,
          tag: 'REPORT',
        ),
        _Notification(
          id: '4',
          icon: Icons.group_outlined,
          color: AppColors.warning,
          title: '8 New Reports Submitted',
          body: '8 new citizen reports have been submitted today. 3 are marked HIGH PRIORITY.',
          time: 'Today, 09:00',
          isRead: true,
          tag: 'INBOX',
        ),
        _Notification(
          id: '5',
          icon: Icons.location_on_outlined,
          color: AppColors.error,
          title: 'Hotspot Alert: Gasabo',
          body: 'Gasabo District now has 142 active critical issues. Field resources may need reallocation.',
          time: 'Yesterday',
          isRead: true,
          tag: 'HOTSPOT',
        ),
      ];

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final n = _notifications.firstWhere((n) => n.id == id);
      n.isRead = true;
    });
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isAdmin;
    final bgColor = isDark ? _adminBg : AppColors.backgroundGrey;
    final cardColor = isDark ? _adminCard : AppColors.backgroundWhite;
    final textColor = isDark ? AppColors.textWhite : AppColors.textPrimary;
    final mutedColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: AppTextStyles.h3.copyWith(color: textColor)),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount unread',
                style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
              ),
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmpty(mutedColor)
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 1),
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return _buildNotificationTile(n, cardColor, textColor, mutedColor);
              },
            ),
    );
  }

  Widget _buildNotificationTile(
    _Notification n,
    Color cardColor,
    Color textColor,
    Color mutedColor,
  ) {
    return GestureDetector(
      onTap: () => _markRead(n.id),
      child: Container(
        color: n.isRead ? cardColor : n.color.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Container(
              margin: const EdgeInsets.only(top: 6, right: 8),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: n.isRead ? Colors.transparent : n.color,
              ),
            ),
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: n.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.icon, color: n.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: n.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          n.tag,
                          style: AppTextStyles.badge.copyWith(color: n.color),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        n.time,
                        style: AppTextStyles.caption.copyWith(color: mutedColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(Color mutedColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_outlined, size: 56, color: mutedColor),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            style: AppTextStyles.h4.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'ll be notified about your report updates here.',
            style: AppTextStyles.bodySmall.copyWith(color: mutedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Notification {
  final String id;
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final String time;
  bool isRead;
  final String tag;

  _Notification({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.tag,
  });
}
