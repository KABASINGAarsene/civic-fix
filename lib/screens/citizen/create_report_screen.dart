import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:district_direct/l10n/app_localizations.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: scheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.createReportTitle,
          style: TextStyle(
            color: scheme.onSurface,
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
                  children: [
                    Text(
                      l10n.step1Of2,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      l10n.captureEvidence,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
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
              Text(
                l10n.issueTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                maxLength: 60,
                decoration: InputDecoration(
                  hintText: l10n.issueTitleHint,
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  filled: true,
                  fillColor: scheme.surface,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.shortDescription,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildDescriptionInput(),
              const SizedBox(height: 32),
              Text(
                l10n.addSupportingMedia,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.supportingMediaHelp,
                style: TextStyle(
                  fontSize: 16,
                  color: scheme.onSurfaceVariant,
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
    final l10n = AppLocalizations.of(context)!;
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
      ).showSnackBar(SnackBar(content: Text('${l10n.cameraOpenFailed}: $e')));
    }
  }

  Widget _buildPhotoUploadContainer() {
    final scheme = Theme.of(context).colorScheme;

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
            child: Text(
              AppLocalizations.of(context)!.tapToChangePhoto,
              style: const TextStyle(
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
          color: scheme.outline,
          strokeWidth: 2.0,
          gap: 6.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: scheme.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.takePhotoOrVideo,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.highQualityPreferred,
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
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
          color: Theme.of(context).scaffoldBackgroundColor,
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
          SnackBar(content: Text(AppLocalizations.of(context)!.microphonePermissionDenied)),
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isRecording
            ? scheme.error.withValues(alpha: 0.12)
            : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecording ? scheme.error : scheme.outline,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.1),
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
                        ? scheme.tertiary
                        : scheme.error,
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
                              ? l10n.voiceMemoSaved
                                : (_isRecording
                                ? l10n.recording
                                : l10n.voiceRecording),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_isRecording)
                          Text(
                            _formatDuration(_recordDuration),
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.error,
                              fontFamily: 'monospace',
                            ),
                          )
                        else if (_audioPath != null ||
                            _existingAudioUrl != null)
                          Text(
                            _existingAudioUrl != null &&
                                    _audioPath == null &&
                                    _playbackDuration == Duration.zero
                                ? l10n.readyToPlay
                                : '${_formatDuration(_playbackPosition.inSeconds)} / ${_formatDuration(_playbackDuration.inSeconds > 0 ? _playbackDuration.inSeconds : _recordDuration)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          )
                        else
                          Text(
                            l10n.limit5Minutes,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isRecording)
                      LinearProgressIndicator(color: scheme.error)
                    else if (_audioPath != null || _existingAudioUrl != null)
                      LinearProgressIndicator(
                        value: _playbackDuration.inMilliseconds > 0
                            ? _playbackPosition.inMilliseconds /
                                  _playbackDuration.inMilliseconds
                            : 0,
                        color: scheme.tertiary,
                        backgroundColor: scheme.tertiary.withValues(alpha: 0.2),
                      )
                    else
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
              if (_audioPath != null || _existingAudioUrl != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: scheme.error,
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        maxLength: 140,
        decoration: InputDecoration(
          hintText: l10n.descriptionHint,
          hintStyle: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 15,
            height: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          counterStyle: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
                child: Text(
                  l10n.saveDraft,
                  style: TextStyle(
                    color: scheme.onSurface,
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
                      SnackBar(
                        content: Text(
                          l10n.provideEvidencePrompt,
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
                  backgroundColor: scheme.primary,
                  elevation: 4,
                  shadowColor: scheme.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.continueLabel,
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: scheme.onPrimary,
                      size: 20,
                    ),
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
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            color: filled ? scheme.primary : scheme.outline,
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
