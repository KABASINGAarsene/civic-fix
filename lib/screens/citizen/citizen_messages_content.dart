import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../home/officer_chat_screen.dart';

class _Conversation {
  final String officerName;
  final String initials;
  final Color avatarColor;
  final String department;
  final String ticketId;
  final String issueTitle;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isResolved;
  final bool isOnline;

  const _Conversation({
    required this.officerName,
    required this.initials,
    required this.avatarColor,
    required this.department,
    required this.ticketId,
    required this.issueTitle,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isResolved = false,
    this.isOnline = false,
  });
}

const _mockConversations = [
  _Conversation(
    officerName: 'Officer Jean Pierre',
    initials: 'JP',
    avatarColor: AppColors.primaryBlue,
    department: 'Infrastructure Dept.',
    ticketId: 'DD-2024-001',
    issueTitle: 'Broken Water Pipe – Gasabo',
    lastMessage: 'Yes, I can see the crew finished. Checking the water pressure now... it looks much better!',
    time: '10:52 AM',
    unreadCount: 0,
    isOnline: true,
  ),
  _Conversation(
    officerName: 'Officer Marie Claire',
    initials: 'MC',
    avatarColor: Color(0xFF6C5CE7),
    department: 'Utilities Dept.',
    ticketId: 'DD-2024-007',
    issueTitle: 'Street Light Failure – Sector 4',
    lastMessage: "We've ordered replacement bulbs. Installation is scheduled for tomorrow morning.",
    time: 'Yesterday',
    unreadCount: 2,
    isOnline: false,
  ),
  _Conversation(
    officerName: 'Officer Patrick Nkurunziza',
    initials: 'PN',
    avatarColor: Color(0xFF00B894),
    department: 'Roads & Transport',
    ticketId: 'DD-2024-013',
    issueTitle: 'Pothole on Kigali Road',
    lastMessage: 'Your report has been received and prioritised. A repair crew will be dispatched shortly.',
    time: 'Mon',
    unreadCount: 1,
    isOnline: false,
  ),
  _Conversation(
    officerName: 'Officer Diane Uwase',
    initials: 'DU',
    avatarColor: Color(0xFFE17055),
    department: 'Sanitation Dept.',
    ticketId: 'DD-2024-019',
    issueTitle: 'Missed Garbage Collection',
    lastMessage: 'The issue has been resolved. Thank you for helping keep our district clean!',
    time: 'Sat',
    unreadCount: 0,
    isResolved: true,
    isOnline: false,
  ),
  _Conversation(
    officerName: 'Officer Celestin Habimana',
    initials: 'CH',
    avatarColor: Color(0xFF0984E3),
    department: 'Health & Safety',
    ticketId: 'DD-2024-025',
    issueTitle: 'Flooding Near Health Centre',
    lastMessage: 'Could you send us a photo of the current drainage situation?',
    time: 'Fri',
    unreadCount: 3,
    isOnline: true,
  ),
];

class CitizenMessagesContent extends StatelessWidget {
  const CitizenMessagesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final totalUnread =
        _mockConversations.fold(0, (sum, c) => sum + c.unreadCount);

    return Column(
      children: [
        _buildHeader(totalUnread),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: _mockConversations.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              indent: 76,
              endIndent: 20,
              color: Color(0xFFF0F0F0),
            ),
            itemBuilder: (context, i) =>
                _buildConversationTile(context, _mockConversations[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalUnread) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages', style: AppTextStyles.h3),
                Text(
                  'Conversations with assigned officers',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (totalUnread > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$totalUnread unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, _Conversation conv) {
    final hasUnread = conv.unreadCount > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfficerChatScreen(
              officerName: conv.officerName,
              department: conv.department,
              ticketId: conv.ticketId,
              issueTitle: conv.issueTitle,
            ),
          ),
        );
      },
      child: Container(
        color: hasUnread
            ? AppColors.primaryBlue.withOpacity(0.03)
            : AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(conv),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.officerName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conv.time,
                        style: AppTextStyles.caption.copyWith(
                          color: hasUnread
                              ? AppColors.primaryBlue
                              : AppColors.textTertiary,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 11,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${conv.ticketId} • ${conv.issueTitle}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.lastMessage,
                          style: AppTextStyles.caption.copyWith(
                            color: hasUnread
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (conv.isResolved)
                        _statusChip('RESOLVED', AppColors.success)
                      else if (conv.unreadCount > 0)
                        _unreadBadge(conv.unreadCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(_Conversation conv) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: conv.avatarColor,
          child: Text(
            conv.initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (conv.isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _unreadBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
