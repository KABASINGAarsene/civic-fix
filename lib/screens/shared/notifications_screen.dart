import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Admin uses a local mutable list; citizen uses a Firestore stream.
  late List<_Notification> _notifications;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _citizenStream;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _notifications = _adminNotifications();
    } else {
      _notifications = [];
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _citizenStream = FirebaseFirestore.instance
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .snapshots();
      }
    }
  }

  static final List<_Notification> _citizenMockNotifications = [
    _Notification(
      id: 'mock_1',
      icon: Icons.chat_outlined,
      color: AppColors.primaryBlue,
      title: 'New Message from Admin',
      body: 'Your report "Broken Water Pipe – Gasabo" has been reviewed. A field team will be dispatched shortly.',
      time: '2h ago',
      isRead: false,
      tag: 'MESSAGE',
    ),
    _Notification(
      id: 'mock_2',
      icon: Icons.chat_outlined,
      color: AppColors.primaryBlue,
      title: 'New Message from Admin',
      body: 'We have scheduled an inspection for your reported pothole on Kigali Road. Expected repair: 2 days.',
      time: 'Yesterday',
      isRead: false,
      tag: 'MESSAGE',
    ),
    _Notification(
      id: 'mock_3',
      icon: Icons.chat_outlined,
      color: AppColors.primaryBlue,
      title: 'New Message from Admin',
      body: 'Thank you for your report on the street light failure. Replacement parts have been ordered.',
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
    if (widget.isAdmin) {
      setState(() {
        final n = _notifications.firstWhere((n) => n.id == id);
        n.isRead = true;
      });
    } else {
      // Mark read in Firestore for citizens.
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        FirebaseFirestore.instance
            .collection('notifications')
            .doc(uid)
            .collection('items')
            .doc(id)
            .update({'isRead': true});
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isAdmin;
    final bgColor = isDark ? _adminBg : AppColors.backgroundGrey;
    final cardColor = isDark ? _adminCard : AppColors.backgroundWhite;
    final textColor = isDark ? AppColors.textWhite : AppColors.textPrimary;
    final mutedColor = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    // Citizen side: use Firestore stream
    if (!widget.isAdmin && _citizenStream != null) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _citizenStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: bgColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          final firestoreItems = docs.map((doc) {
            final d = doc.data();
            final ts = (d['createdAt'] as Timestamp?)?.toDate();
            return _Notification(
              id: doc.id,
              icon: Icons.chat_outlined,
              color: AppColors.primaryBlue,
              title: (d['title'] as String?) ?? 'New Message',
              body: (d['body'] as String?) ?? '',
              time: _timeAgo(ts),
              isRead: (d['isRead'] as bool?) ?? false,
              tag: (d['tag'] as String?) ?? 'MESSAGE',
            );
          }).toList();

          // Fall back to mock admin messages while there are no real ones yet.
          final items = firestoreItems.isNotEmpty
              ? firestoreItems
              : _citizenMockNotifications;

          final unread = items.where((n) => !n.isRead).length;

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
                  Text('Notifications',
                      style: AppTextStyles.h3.copyWith(color: textColor)),
                  if (unread > 0)
                    Text(
                      '$unread unread',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primaryBlue),
                    ),
                ],
              ),
            ),
            body: items.isEmpty
                ? _buildEmpty(mutedColor)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 1),
                    itemBuilder: (context, i) => _buildNotificationTile(
                        items[i], cardColor, textColor, mutedColor),
                  ),
          );
        },
      );
    }

    // Admin side: local list
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

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
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
