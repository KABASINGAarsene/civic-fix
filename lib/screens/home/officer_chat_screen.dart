import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';

class OfficerChatScreen extends StatefulWidget {
  final String officerName;
  final String department;
  final String ticketId;
  final String issueTitle;

  const OfficerChatScreen({
    super.key,
    required this.officerName,
    required this.department,
    required this.ticketId,
    required this.issueTitle,
  });

  @override
  State<OfficerChatScreen> createState() => _OfficerChatScreenState();
}

class _OfficerChatScreenState extends State<OfficerChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _caseResolved = false;

  // Sample conversation matching the design
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      const ChatMessage(
        id: 'm1',
        text:
            'Hello, I have reviewed your report regarding the broken water pipe in Gasabo. Our field team has just completed the repairs.',
        isOfficer: true,
        time: '10:45 AM',
      ),
      const ChatMessage(
        id: 'm2',
        text: 'Please see the attached photo of the fix. Can you confirm if the water pressure has returned to normal?',
        isOfficer: true,
        time: '10:46 AM',
        hasImage: true,
      ),
      const ChatMessage(
        id: 'm3',
        text:
            'Yes, I can see the crew finished. Checking the water pressure now... it looks much better! Thank you for the quick response.',
        isOfficer: false,
        time: '10:52 AM',
      ),
    ];
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        isOfficer: false,
        time: _nowTime(),
      ));
    });
    _inputController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showCaseLog(BuildContext context) {
    final events = [
      ('09:15 AM', 'Citizen submitted report', Icons.flag_outlined, AppColors.primaryBlue),
      ('09:30 AM', 'Report verified by system', Icons.check_circle_outline, AppColors.success),
      ('09:30 AM', '${widget.officerName} assigned to case', Icons.person_outline, AppColors.primaryBlue),
      ('10:00 AM', 'Officer dispatched to location', Icons.directions_car_outlined, AppColors.warning),
      ('10:45 AM', 'Field team completed repairs', Icons.build_outlined, AppColors.success),
      ('10:46 AM', 'Resolution photo uploaded', Icons.photo_camera_outlined, AppColors.success),
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Case Log & History',
                style: AppTextStyles.h4),
            Text('Ticket #${widget.ticketId}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: events.length,
                itemBuilder: (_, i) {
                  final e = events[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: e.$4.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(e.$3, color: e.$4, size: 17),
                            ),
                            if (i < events.length - 1)
                              Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.grey.shade200),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(e.$2,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(e.$1,
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildAppBar(context),
          _buildStatusChips(),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildDaySeparator('TODAY'),
                const SizedBox(height: 16),
                _buildSystemEvent(
                  Icons.person_outline,
                  'Officer assigned to case • 09:30 AM',
                ),
                const SizedBox(height: 6),
                _buildSystemEvent(
                  Icons.location_on_outlined,
                  'Reporting issue at: KG 201 St, Kigali',
                ),
                const SizedBox(height: 20),
                ..._messages.map(_buildMessage),
                if (!_caseResolved) ...[
                  const SizedBox(height: 8),
                  _buildResolutionPrompt(),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          _buildInputBar(),
          // Case log link
          GestureDetector(
            onTap: () => _showCaseLog(context),
            child: Container(
              color: AppColors.backgroundWhite,
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt_outlined,
                      color: AppColors.primaryBlue, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'View Case Log & History',
                    style: AppTextStyles.link.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.backgroundWhite,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios,
                  color: AppColors.primaryBlue, size: 16),
              label: const Text(
                'Back',
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.officerName,
                    style: AppTextStyles.h4.copyWith(fontSize: 16),
                  ),
                  Text(
                    widget.department,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: AppColors.primaryBlue, size: 22),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Call ${widget.officerName}'),
                    content: Text(
                        'Initiating call to ${widget.officerName} – ${widget.department}...'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Status chips (ticket ID + verification status)

  Widget _buildStatusChips() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _chip('#${widget.ticketId}', AppColors.primaryBlue,
              AppColors.primaryBlue.withOpacity(0.12)),
          const SizedBox(width: 8),
          _chip('PENDING VERIFICATION', const Color(0xFFFFC107),
              const Color(0xFFFFF8E1)),
        ],
      ),
    );
  }

  Widget _chip(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Day separator

  Widget _buildDaySeparator(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFDDDDDD))),
      ],
    );
  }

  // System event (centered muted text)

  Widget _buildSystemEvent(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary, fontSize: 12),
        ),
      ],
    );
  }

  // Chat message bubble

  Widget _buildMessage(ChatMessage msg) {
    if (msg.isOfficer) {
      return _buildOfficerBubble(msg);
    } else {
      return _buildCitizenBubble(msg);
    }
  }

  Widget _buildOfficerBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.grey, size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                  ),
                ),
                if (msg.hasImage) ...[
                  const SizedBox(height: 6),
                  _buildImageBubble(),
                ],
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '${widget.officerName} • ${msg.time}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildImageBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        height: 140,
        color: const Color(0xFF2A3548),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pipe visual
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 30,
                  color: Colors.grey.shade400,
                ),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 6,
              right: 8,
              child: const Icon(Icons.zoom_in,
                  color: Colors.white54, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitizenBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Resolution prompt

  Widget _buildResolutionPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Has this issue been resolved to your satisfaction?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your verification closes this case officially.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _caseResolved = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Case marked as resolved. Thank you!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Confirm Fix',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Case re-opened. Officer notified.'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Re-open',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Message input bar

  Widget _buildInputBar() {
    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.caption
                      .copyWith(color: AppColors.textTertiary, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
