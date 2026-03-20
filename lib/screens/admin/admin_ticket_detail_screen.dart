import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';

class AdminTicketDetailScreen extends StatefulWidget {
  final AdminIssue issue;

  const AdminTicketDetailScreen({super.key, required this.issue});

  @override
  State<AdminTicketDetailScreen> createState() =>
      _AdminTicketDetailScreenState();
}

class _AdminTicketDetailScreenState extends State<AdminTicketDetailScreen> {
  static const Color _bg = Color(0xFF111827);
  static const Color _card = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);
  static const Color _blue = AppColors.primaryBlue;

  String _selectedStatus = 'In Progress';
  final _messageController = TextEditingController();
  bool _isPlaying = false;

  static const _statusOptions = [
    'Submitted',
    'In Progress',
    'Resolved',
  ];

  static const _messageChips = [
    'Team Dispatched',
    'Awaiting Parts',
    'Inspection Scheduled',
    'On Hold',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ticket #${widget.issue.id}',
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEvidencePhoto(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVoiceNote(),
                  const SizedBox(height: 14),
                  _buildMiniMap(),
                  const SizedBox(height: 20),
                  _buildSendUpdateButton(),
                  const SizedBox(height: 14),
                  _buildStatusDropdown(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('MESSAGE TO CITIZEN'),
                  const SizedBox(height: 12),
                  _buildMessageChips(),
                  const SizedBox(height: 12),
                  _buildMessageInput(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('RESOLUTION SECTION'),
                  const SizedBox(height: 12),
                  _buildResolutionUpload(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Evidence Photo

  Widget _buildEvidencePhoto() {
    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFF2A3548),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.water_drop,
            size: 80,
            color: Colors.white.withOpacity(0.15),
          ),
          // Simulated pipe/water leak visual
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 20,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Evidence Photo',
                style: AppTextStyles.caption.copyWith(
                    color: Colors.white70, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Voice Note Player

  Widget _buildVoiceNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mic, color: _blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Citizen Voice Note',
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '0:45 Duration • ${widget.issue.location}',
                      style: AppTextStyles.caption.copyWith(color: _textMuted),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Waveform bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(28, (i) {
              final heights = [
                8.0, 14.0, 10.0, 18.0, 12.0, 20.0, 8.0, 16.0, 22.0, 10.0,
                14.0, 18.0, 8.0, 24.0, 12.0, 16.0, 20.0, 8.0, 14.0, 18.0,
                10.0, 16.0, 22.0, 8.0, 14.0, 10.0, 18.0, 12.0,
              ];
              final isActive = i < 10; // first third "played"
              return Container(
                width: 3,
                height: heights[i % heights.length],
                decoration: BoxDecoration(
                  color: isActive
                      ? _blue
                      : _textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0:12',
                  style: AppTextStyles.caption.copyWith(color: _textMuted)),
              Text('0:45',
                  style: AppTextStyles.caption.copyWith(color: _textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  // Mini Map

  Widget _buildMiniMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 150,
        child: Stack(
          children: [
            // Map background
            Container(
              color: const Color(0xFFD1E8C4),
              child: CustomPaint(
                painter: _MapPainter(),
                child: Container(),
              ),
            ),
            // Location pin
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_pin,
                      color: AppColors.error, size: 32),
                  Container(
                    width: 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Open in Maps button
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Open in Maps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Send Update Button

  Widget _buildSendUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Update sent to citizen'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
        icon: const Icon(Icons.send, color: Colors.white, size: 18),
        label: const Text(
          'Send Update',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Status Dropdown

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _textMuted.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          dropdownColor: _card,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite),
          style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w500),
          onChanged: (v) {
            if (v != null) setState(() => _selectedStatus = v);
          },
          items: _statusOptions
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // Section Label

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.captionBold.copyWith(
        color: _textMuted,
        letterSpacing: 1.2,
        fontSize: 11,
      ),
    );
  }

  // Message Chips

  Widget _buildMessageChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _messageChips.map((chip) {
          return GestureDetector(
            onTap: () {
              _messageController.text = chip;
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _textMuted.withOpacity(0.4)),
              ),
              child: Text(
                chip,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textWhite, fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Message Text Input

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _textMuted.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 4,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Describe the action taken or progress update...',
          hintStyle: TextStyle(color: _textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  // Resolution Upload

  Widget _buildResolutionUpload() {
    return GestureDetector(
      onTap: () {}, // TODO: pick image
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _blue.withOpacity(0.5),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: _blue,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload Resolution Photo',
              style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Mandatory for ticket completion',
              style: AppTextStyles.caption.copyWith(color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw simple road lines on the mini-map
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );
    // Diagonal road
    paint.strokeWidth = 4;
    paint.color = Colors.white.withOpacity(0.4);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * 0.4, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
