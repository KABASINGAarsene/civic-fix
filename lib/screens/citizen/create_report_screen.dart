import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({Key? key}) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _imageFile;
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  String? _editDocId;
  String? _category;
  String? _district;
  String? _sector;
  double? _priority;
  bool? _isAnonymous;
  String? _existingPhotoUrl;
  String? _existingAudioUrl;
  String? _manualLocation;
  bool _isInitialized = false;

  int _recordDuration = 0;
  Timer? _recordTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted)
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted)
        setState(() {
          _playbackDuration = newDuration;
        });
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted)
        setState(() {
          _playbackPosition = newPosition;
        });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (!_isInitialized && args != null) {
      if (args['title'] != null) {
        _titleController.text = args['title'] as String;
      }
      if (args['description'] != null) {
        _descriptionController.text = args['description'] as String;
      }
      _editDocId = args['docId'] as String?;
      _category = args['category'] as String?;
      _district = args['district'] as String?;
      _sector = args['sector'] as String?;
      _priority = (args['priority'] as num?)?.toDouble();
      _isAnonymous = args['is_anonymous'] as bool?;
      _existingPhotoUrl = args['photo_url'] as String?;
      _existingAudioUrl = args['audio_url'] as String?;
      _manualLocation = args['manual_location'] as String?;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0A4DDE)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Report',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'STEP 1 OF 2',
                      style: TextStyle(
                        color: Color(0xFF0A4DDE),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Capture Evidence',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _stepBar(true, onTap: null),
                    const SizedBox(width: 4),
                    _stepBar(false, onTap: null),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Issue Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: 'e.g. Broken pipe on KG 11 Ave',
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF0A4DDE),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Short Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              _buildDescriptionInput(),
              const SizedBox(height: 32),
              const Text(
                'Add supporting media',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'DistrictDirect uses media to ensure transparency and faster resolution. Attach photos or record a voice memo.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildPhotoUploadContainer(),
              const SizedBox(height: 24),
              _buildVoiceRecordContainer(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, // Compress slightly
      );
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to open camera: $e')));
    }
  }

  Widget _buildPhotoUploadContainer() {
    Widget photoWidget;
    if (_imageFile != null) {
      photoWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: kIsWeb
            ? Image.network(
                _imageFile!.path,
                fit: BoxFit.cover,
                height: 260,
                width: double.infinity,
              )
            : Image.file(
                File(_imageFile!.path),
                fit: BoxFit.cover,
                height: 260,
                width: double.infinity,
              ),
      );
    } else if (_existingPhotoUrl != null) {
      photoWidget = Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _existingPhotoUrl!,
              fit: BoxFit.cover,
              height: 260,
              width: double.infinity,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Tap to Change Photo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else {
      photoWidget = CustomPaint(
        painter: DashedRectPainter(
          color: const Color(0xFFD1D5DB),
          strokeWidth: 2.0,
          gap: 6.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF0A4DDE),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Take Photo or Video',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'High quality preferred',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _takePhoto,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: photoWidget,
      ),
    );
  }

  void _startTimer() {
    _recordDuration = 0;
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() => _recordDuration++);
        if (_recordDuration >= 300) _toggleRecording(); // 5 min max
      }
    });
  }

  Future<void> _toggleRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (_isRecording) {
          final path = await _audioRecorder.stop();
          _recordTimer?.cancel();
          setState(() {
            _isRecording = false;
            _audioPath = path;
          });
        } else {
          // Reset old path
          setState(() {
            _audioPath = null;
          });
          await _audioRecorder.start(
            const RecordConfig(),
            path: 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
          setState(() {
            _isRecording = true;
          });
          _startTimer();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied.')),
        );
      }
    } catch (e) {
      print('Audio recording error: $e');
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlayback() async {
    String? source = _audioPath ?? _existingAudioUrl;
    if (source == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_existingAudioUrl != null && _audioPath == null) {
        await _audioPlayer.play(UrlSource(_existingAudioUrl!));
      } else {
        await _audioPlayer.play(DeviceFileSource(_audioPath!));
      }
    }
  }

  void _deleteAudio() {
    _recordTimer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _audioPath = null;
      _existingAudioUrl = null;
      _recordDuration = 0;
      _isPlaying = false;
      _playbackPosition = Duration.zero;
      _playbackDuration = Duration.zero;
    });
  }

  Widget _buildVoiceRecordContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isRecording ? const Color(0xFFFEE2E2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecording
              ? const Color(0xFFEF4444)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: (_audioPath != null || _existingAudioUrl != null)
                    ? _togglePlayback
                    : _toggleRecording,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_audioPath != null || _existingAudioUrl != null)
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (_audioPath != null || _existingAudioUrl != null)
                        ? (_isPlaying ? Icons.pause : Icons.play_arrow)
                        : (_isRecording ? Icons.stop : Icons.mic),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _audioPath != null
                                ? 'Voice Memo Saved'
                                : (_isRecording
                                      ? 'Recording...'
                                      : 'Voice Recording'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isRecording)
                          Text(
                            _formatDuration(_recordDuration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                              fontFamily: 'monospace',
                            ),
                          )
                        else if (_audioPath != null ||
                            _existingAudioUrl != null)
                          Text(
                            _existingAudioUrl != null &&
                                    _audioPath == null &&
                                    _playbackDuration == Duration.zero
                                ? 'Ready to play'
                                : '${_formatDuration(_playbackPosition.inSeconds)} / ${_formatDuration(_playbackDuration.inSeconds > 0 ? _playbackDuration.inSeconds : _recordDuration)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontFamily: 'monospace',
                            ),
                          )
                        else
                          const Text(
                            '05:00 limit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isRecording)
                      const LinearProgressIndicator(color: Color(0xFFEF4444))
                    else if (_audioPath != null || _existingAudioUrl != null)
                      LinearProgressIndicator(
                        value: _playbackDuration.inMilliseconds > 0
                            ? _playbackPosition.inMilliseconds /
                                  _playbackDuration.inMilliseconds
                            : 0,
                        color: const Color(0xFF10B981),
                        backgroundColor: const Color(0xFFD1FAE5),
                      )
                    else
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
              if (_audioPath != null || _existingAudioUrl != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFEF4444),
                  ),
                  onPressed: _deleteAudio,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        maxLength: 140,
        decoration: InputDecoration(
          hintText:
              'Briefly describe the issue (e.g. Broken\nstreetlight on KG 201 St)...',
          hintStyle: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 15,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: const Color(0xFFF8F9FA)),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFF3F4F6),
                ),
                child: const Text(
                  'Save Draft',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  if (_imageFile == null &&
                      _audioPath == null &&
                      _descriptionController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please capture a photo, audio, or write a description.',
                        ),
                      ),
                    );
                    return;
                  }

                  // Navigate to report incident form
                  Navigator.pushNamed(
                    context,
                    '/report-incident',
                    arguments: {
                      'docId': _editDocId,
                      'imageFile': _imageFile,
                      'audioPath': _audioPath,
                      'title': _titleController.text.trim(),
                      'description': _descriptionController.text.trim(),
                      'category': _category,
                      'district': _district,
                      'sector': _sector,
                      'priority': _priority,
                      'is_anonymous': _isAnonymous,
                      'manual_location': _manualLocation,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0A4DDE),
                  elevation: 4,
                  shadowColor: const Color(0xFF0A4DDE).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBar(bool filled, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            color: filled ? const Color(0xFF0A4DDE) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Dashed Rect
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    Path dashPath = Path();
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
