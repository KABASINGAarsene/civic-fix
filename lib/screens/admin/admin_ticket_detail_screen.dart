import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/dashboard_models.dart';
import '../../state/admin_dashboard_provider.dart';
import '../home/officer_chat_screen.dart';

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
  late AudioPlayer _audioPlayer;
  VideoPlayerController? _videoController;
  String? _loadedAudioPath;
  bool _isUpdatingStatus = false;
  bool _isSendingMessage = false;

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
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _selectedStatus = _labelFromStatus(widget.issue.status);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _audioPlayer.dispose();
    _videoController?.dispose();
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
                  _buildIssueDetailsCard(),
                  const SizedBox(height: 14),
                  _buildOpenConversationButton(context),
                  const SizedBox(height: 14),
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

  // Evidence Photo/Video Gallery

  Widget _buildEvidencePhoto() {
    final media = widget.issue.attachedMedia;
    
    // If no media, show placeholder
    if (media.isEmpty) {
      return Container(
        width: double.infinity,
        height: 220,
        color: const Color(0xFF2A3548),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 80,
              color: Colors.white.withOpacity(0.15),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No Media Attached',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Citizen has not attached any photos or videos',
                  style: AppTextStyles.caption.copyWith(
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show first media or multi-select gallery
    final firstMedia = media.first;
    final isVideo = _isVideoPath(firstMedia);

    return Container(
      width: double.infinity,
      height: 220,
      color: const Color(0xFF2A3548),
      child: isVideo
          ? _buildVideoPreview(firstMedia)
          : _buildImagePreview(firstMedia),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return GestureDetector(
      onTap: () {
        if (widget.issue.attachedMedia.length > 1) {
          _showMediaGallery();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Try to display the image
          _isRemotePath(imagePath)
              ? Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
              : _fileExists(imagePath)
              ? Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
          // Label
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image, color: Colors.white, size: 12),
                  const SizedBox(width: 6),
                  Text(
                    'Evidence Photo${widget.issue.attachedMedia.length > 1 ? ' (${widget.issue.attachedMedia.length}) View All' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(String videoPath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: _isRemotePath(videoPath) || _fileExists(videoPath)
              ? _VideoThumbnail(
                  videoPath: videoPath,
                  isRemote: _isRemotePath(videoPath),
                )
              : Center(
                  child: Icon(
                    Icons.videocam,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
        ),
        // Play button overlay
        Positioned(
          bottom: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, color: Colors.white, size: 12),
                const SizedBox(width: 6),
                Text(
                  'Evidence Video',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Tap to play
        Center(
          child: GestureDetector(
            onTap: () => _showVideoPlayer(videoPath),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF2A3548),
      child: Icon(
        Icons.image,
        size: 80,
        color: Colors.white.withOpacity(0.2),
      ),
    );
  }

  bool _isVideoPath(String path) {
    final ext = path.toLowerCase().split('.').last;
    return ['mp4', 'mov', 'avi', 'mkv', 'flv', 'webm'].contains(ext);
  }

  bool _fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  void _showMediaGallery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Media Gallery (${widget.issue.attachedMedia.length})',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PageView.builder(
            itemCount: widget.issue.attachedMedia.length,
            itemBuilder: (context, index) {
              final mediaPath = widget.issue.attachedMedia[index];
              final isVideo = _isVideoPath(mediaPath);

              return isVideo
                  ? Center(
                      child: GestureDetector(
                        onTap: () => _showVideoPlayer(mediaPath),
                        child: Container(
                          color: Colors.black,
                          child: Center(
                            child: _fileExists(mediaPath)
                              || _isRemotePath(mediaPath)
                              ? _VideoThumbnail(
                                videoPath: mediaPath,
                                isRemote: _isRemotePath(mediaPath),
                                )
                                : Icon(
                                    Icons.videocam,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                          ),
                        ),
                      ),
                    )
                  : _fileExists(mediaPath)
                      || _isRemotePath(mediaPath)
                      ? PhotoView(
                        imageProvider: _isRemotePath(mediaPath)
                          ? NetworkImage(mediaPath)
                          : FileImage(File(mediaPath)) as ImageProvider,
                      )
                      : Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 56,
                            color: Colors.white.withOpacity(0.45),
                          ),
                        );
            },
          ),
        ),
      ),
    );
  }

  void _showVideoPlayer(String videoPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: _VideoPlayerScreen(
              videoPath: videoPath,
              isRemote: _isRemotePath(videoPath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _textMuted.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPORT DETAILS',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('Category', widget.issue.category),
          const SizedBox(height: 8),
          _detailRow('Address', widget.issue.address.isNotEmpty ? widget.issue.address : widget.issue.location),
          const SizedBox(height: 8),
          _detailRow('Priority', widget.issue.priorityLabel),
          const SizedBox(height: 8),
          _detailRow('Status', _labelFromStatus(widget.issue.status)),
          const SizedBox(height: 8),
          _detailRow('Reported', widget.issue.timeAgo),
          const SizedBox(height: 10),
          const Text(
            'Description',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.issue.description.trim().isEmpty
                ? 'No description provided by citizen.'
                : widget.issue.description,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            '$label:',
            style: TextStyle(
              color: _textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // Voice Note Player (Audio Description)

  Widget _buildVoiceNote() {
    final audioPath = _resolvedAudioPath();
    if (!widget.issue.hasAudioDescription || audioPath == null || audioPath.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
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
                    'Citizen Audio Description',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No playable audio file found in this report.',
                    style: AppTextStyles.caption.copyWith(color: _textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<PlayerState?>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

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
                          'Citizen Audio Description',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        StreamBuilder<Duration?>(
                          stream: _audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ?? Duration.zero;
                            return Text(
                              '${_formatClock(duration)} • ${widget.issue.location}',
                              style: AppTextStyles.caption.copyWith(color: _textMuted),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toggleAudioPlayback(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<Duration?>(
                stream: _audioPlayer.positionStream,
                builder: (context, positionSnapshot) {
                  final position = positionSnapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration?>(
                    stream: _audioPlayer.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      final progress = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;

                      return SliderTheme(
                        data: const SliderThemeData(trackHeight: 4),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (v) {
                            final newPosition = Duration(
                              milliseconds: (v * duration.inMilliseconds).toInt(),
                            );
                            _audioPlayer.seek(newPosition);
                          },
                          activeColor: _blue,
                          inactiveColor: _textMuted.withOpacity(0.3),
                        ),
                      );
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<Duration?>(
                    stream: _audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return Text(
                        _formatClock(position),
                        style: AppTextStyles.caption.copyWith(color: _textMuted),
                      );
                    },
                  ),
                  StreamBuilder<Duration?>(
                    stream: _audioPlayer.durationStream,
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return Text(
                        _formatClock(duration),
                        style: AppTextStyles.caption.copyWith(color: _textMuted),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleAudioPlayback() async {
    final audioPath = _resolvedAudioPath();
    if (audioPath == null || audioPath.isEmpty) {
      return;
    }

    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.audioSource == null || _loadedAudioPath != audioPath) {
          if (_isRemotePath(audioPath)) {
            await _audioPlayer.setUrl(audioPath);
          } else {
            await _audioPlayer.setFilePath(audioPath);
          }
          _loadedAudioPath = audioPath;
        }
        await _audioPlayer.play();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to play this audio file.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String? _resolvedAudioPath() {
    if (widget.issue.audioPath != null && widget.issue.audioPath!.isNotEmpty) {
      return widget.issue.audioPath;
    }

    for (final mediaPath in widget.issue.attachedMedia) {
      if (_isAudioPath(mediaPath)) {
        return mediaPath;
      }
    }

    return null;
  }

  bool _isAudioPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.ogg');
  }

  bool _isRemotePath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  String _formatClock(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Opening maps for: ${widget.issue.location}'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
            ),
          ],
        ),
      ),
    );
  }

  // Open Conversation Button

  Widget _buildOpenConversationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OfficerChatScreen(
                officerName: 'Admin',
                department: 'District Authority',
                ticketId: widget.issue.id,
                issueTitle: widget.issue.title,
              ),
            ),
          );
        },
        icon: const Icon(Icons.chat_outlined, size: 18, color: _blue),
        label: const Text(
          'Open Conversation with Citizen',
          style: TextStyle(
            color: _blue,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        onPressed: _isSendingMessage
            ? null
            : () async {
                final text = _messageController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Write a message before sending.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }

                setState(() {
                  _isSendingMessage = true;
                });

                try {
                  await context.read<AdminDashboardProvider>().sendMessage(
                        issueId: widget.issue.id,
                        text: text,
                        senderRole: 'admin',
                      );

                  if (!mounted) {
                    return;
                  }

                  _messageController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Update sent to citizen'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } catch (_) {
                  if (!mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Failed to send update.'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSendingMessage = false;
                    });
                  }
                }
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
          onChanged: _isUpdatingStatus
              ? null
              : (v) async {
                  if (v == null) {
                    return;
                  }

                  setState(() {
                    _selectedStatus = v;
                    _isUpdatingStatus = true;
                  });

                  try {
                    await context.read<AdminDashboardProvider>().updateIssueStatus(
                          issueId: widget.issue.id,
                          status: _statusFromLabel(v),
                        );

                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status updated to $v'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } catch (_) {
                    if (!mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to update status.'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isUpdatingStatus = false;
                      });
                    }
                  }
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

  String _statusFromLabel(String value) {
    switch (value) {
      case 'Submitted':
        return 'submitted';
      case 'Resolved':
        return 'resolved';
      case 'In Progress':
      default:
        return 'inProgress';
    }
  }

  String _labelFromStatus(String value) {
    switch (value) {
      case 'submitted':
        return 'Submitted';
      case 'resolved':
        return 'Resolved';
      case 'inProgress':
      default:
        return 'In Progress';
    }
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
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Opening camera to capture resolution photo...'),
            backgroundColor: AppColors.primaryBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
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

// Video Thumbnail Widget
class _VideoThumbnail extends StatefulWidget {
  final String videoPath;
  final bool isRemote;

  const _VideoThumbnail({
    required this.videoPath,
    required this.isRemote,
  });

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.isRemote
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        : VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }
}

// Video Player Screen
class _VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final bool isRemote;

  const _VideoPlayerScreen({
    required this.videoPath,
    required this.isRemote,
  });

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.isRemote
        ? VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
        : VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withOpacity(0.3),
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
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
