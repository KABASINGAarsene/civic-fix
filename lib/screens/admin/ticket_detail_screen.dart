import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String? ticketId;

  const TicketDetailScreen({Key? key, this.data, this.ticketId}) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Map<String, dynamic>? _currentData;
  String? _currentTicketId;
  bool _isFetching = false;
  String _selectedStatus = 'Submitted';
  final TextEditingController _updateController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isAudioLoading = false;
  XFile? _imageFile;
  bool _isUpdating = false;

  final List<String> _quickReplies = [
    'Team Dispatched',
    'Awaiting Parts',
    'Inspection Scheduled',
  ];

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    _currentTicketId = widget.ticketId;
    
    if (_currentData == null && _currentTicketId != null) {
      _fetchTicketData();
    } else if (_currentData != null) {
      _selectedStatus = _currentData!['status'] ?? 'Submitted';
    }
    
    // Audio Player Listeners
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  @override
  void dispose() {
    _updateController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio() async {
    final audioUrl = _currentData?['audio_url'];
    if (audioUrl == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        if (_position == Duration.zero) {
          setState(() => _isAudioLoading = true);
          await _audioPlayer.play(UrlSource(audioUrl));
          setState(() => _isAudioLoading = false);
        } else {
          await _audioPlayer.resume();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isAudioLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error playing audio: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _fetchTicketData() async {
    if (_currentTicketId == null) return;
    setState(() => _isFetching = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('issues')
          .doc(_currentTicketId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _currentData = doc.data();
          _selectedStatus = _currentData?['status'] ?? 'Submitted';
          _isFetching = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching ticket: $e');
      if (mounted) setState(() => _isFetching = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  static const String _cloudinaryCloudName = 'doigncrt4';
  static const String _cloudinaryUploadPreset = 'civic-fix';

  Future<String?> _uploadToCloudinary(List<int> bytes, String resourceType, String publicId) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/$resourceType/upload');
      
      final cleanFilename = '${publicId}.jpg';
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _cloudinaryUploadPreset
        ..fields['public_id'] = publicId
        ..fields['filename_override'] = cleanFilename
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: cleanFilename,
          ),
        );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['secure_url'] as String?;
      } else {
        debugPrint('Cloudinary error: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch maps.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_isFetching) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: scheme.primary)),
      );
    }

    if (_currentData == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor, elevation: 0),
        body: Center(
          child: Text('Ticket not found or session expired.', style: TextStyle(color: scheme.onSurface)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: scheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ticket #${(_currentTicketId ?? "").substring(0, 8).toUpperCase()}',
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageHeader(),
            const SizedBox(height: 16),
            _buildCitizenDetailsPanel(),
            const SizedBox(height: 16),
            _buildVoiceNotePlayer(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildActionPanel(),
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    final String? imageUrl = _currentData?['photo_url'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageUrl != null 
        ? Image.network(
            imageUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder('Image could not be loaded'),
          )
        : _buildImagePlaceholder('No photo provided'),
    );
  }

  Widget _buildImagePlaceholder(String message) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 220,
      color: scheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: scheme.onSurfaceVariant, size: 48),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildCitizenDetailsPanel() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CITIZEN DETAILS',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentData?['userName'] ?? 'Citizen User',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentData?['phone'] ?? 'Phone Private',
                      style: TextStyle(
                        color: scheme.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pin_drop, color: scheme.onSurfaceVariant, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentData?['district'] ?? ''} / ${_currentData?['sector'] ?? ''}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNotePlayer() {
    final scheme = Theme.of(context).colorScheme;
    final audioUrl = _currentData?['audio_url'];
    if (audioUrl == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.mic, color: scheme.secondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citizen Voice Note',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDuration(_duration)} Duration • ${_currentData?['sector'] ?? 'Unknown'}',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: _isAudioLoading 
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    )
                  : IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    onPressed: _toggleAudio,
                  ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Audio Progress Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.outline,
              thumbColor: scheme.primary,
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
              Text(_formatDuration(_duration), style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final scheme = Theme.of(context).colorScheme;
    final double? lat = _currentData?['latitude'];
    final double? lng = _currentData?['longitude'];
    final String manualLoc = _currentData?['manual_location'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Map Placeholder / Button
        if (lat != null && lng != null)
        InkWell(
          onTap: () => _openInMaps(lat, lng),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80'), // map
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.map, color: Colors.white, size: 14),
                        const SizedBox(width: 8),
                        const Text(
                          'Open in Google Maps',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (lat != null && lng != null) const SizedBox(height: 12),
        // Fallback Written Description Box
        if (manualLoc.isNotEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.directions, color: scheme.secondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citizen Provided Location',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"$manualLoc"',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateTicketStatus() async {
    if (_selectedStatus == 'Resolved' && _imageFile == null && _currentData?['resolution_photo_url'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a resolution photo to complete this ticket.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final messageText = _updateController.text.trim();
      String? resolutionPhotoUrl;

      // 1. Upload Resolution Photo if provided
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        resolutionPhotoUrl = await _uploadToCloudinary(bytes, 'image', 'resolution_${_currentTicketId}_$timestamp');
      }
      
      // 2. Update Issue Status
      final Map<String, dynamic> updateData = {
        'status': _selectedStatus,
      };
      if (resolutionPhotoUrl != null) {
        updateData['resolution_photo_url'] = resolutionPhotoUrl;
      }

      await FirebaseFirestore.instance
          .collection('issues')
          .doc(_currentTicketId)
          .update(updateData);

      // 3. If message is provided OR status is changed, create/update Chat thread
      final citizenUid = _currentData?['reported_by_uid'];
      final adminUid = FirebaseAuth.instance.currentUser?.uid;
      
      if (citizenUid != null && adminUid != null) {
        // Use ticketId as the unique chat thread identifier for this issue
        final chatRef = FirebaseFirestore.instance.collection('chats').doc(_currentTicketId);
        final messagesRef = chatRef.collection('messages');

        // Always update chat session metadata
        await chatRef.set({
          'ticketId': _currentTicketId,
          'citizenUid': citizenUid,
          'adminUid': adminUid,
          'lastMessage': messageText.isNotEmpty ? messageText : 'Status updated to $_selectedStatus',
          'lastTimestamp': FieldValue.serverTimestamp(),
          'citizenName': _currentData?['reporter_name'] ?? 'Citizen User',
          'ticketTitle': _currentData?['title'] ?? 'Ticket Update',
          'status': _selectedStatus,
        }, SetOptions(merge: true));

        // Send text message if provided
        if (messageText.isNotEmpty) {
          await messagesRef.add({
            'senderId': adminUid,
            'receiverId': citizenUid,
            'text': messageText,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'text',
          });
        }

        // Send Resolution Photo as a chat message if status is Resolved
        if (_selectedStatus == 'Resolved' && resolutionPhotoUrl != null) {
          await messagesRef.add({
            'senderId': adminUid,
            'receiverId': citizenUid,
            'text': 'Proof of Resolution',
            'attachmentUrl': resolutionPhotoUrl,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'type': 'image',
          });
        }
      }

      if (mounted) {
        _updateController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated and citizen notified!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Widget _buildActionPanel() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Action Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isUpdating ? null : _updateTicketStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isUpdating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      'Send Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                const SizedBox(width: 8),
                if (!_isUpdating) const Icon(Icons.send, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Status Dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.45)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: (_selectedStatus == 'Received') ? 'Submitted' : _selectedStatus,
              isExpanded: true,
              dropdownColor: scheme.surface,
              icon: Icon(Icons.keyboard_arrow_down, color: scheme.onSurface),
              style: TextStyle(color: scheme.onSurface, fontSize: 16),
              items: <String>['Submitted', 'Assigned', 'Field Visit', 'Resolved'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Message to Citizen
        Text(
          'MESSAGE TO CITIZEN',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _quickReplies.map((reply) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _updateController.text = reply;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.outline.withValues(alpha: 0.8)),
                    ),
                    child: Text(
                      reply,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _updateController,
          maxLines: 4,
          style: TextStyle(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Describe the action taken or progress update...',
            hintStyle: TextStyle(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Resolution Section (Only show if Resolved)
        if (_selectedStatus == 'Resolved') ...[
          const SizedBox(height: 24),
          Text(
            'RESOLUTION SECTION',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.primary.withOpacity(0.5),
                  style: BorderStyle.none,
                ),
              ),
              child: Column(
                children: [
                  if (_imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_imageFile!.path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Photo Selected ✅',
                      style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: scheme.secondary, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Resolution Photo',
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mandatory for ticket completion',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
