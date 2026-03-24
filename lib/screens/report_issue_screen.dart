import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/dashboard_models.dart';
import '../state/citizen_home_provider.dart';
import 'report/report_confirmation_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  final ReportItem? editingIssue;

  const ReportIssueScreen({super.key, this.editingIssue});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const List<String> _allCategories = [
    'Infrastructure',
    'Health',
    'Security',
    'Land',
    'Justice',
    'Education',
  ];

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  final Set<String> _selectedCategories = <String>{};
  final List<_AttachedMedia> _attachedMedia = [];

  bool _useAudioDescription = false;
  bool _isRecordingAudio = false;
  bool _hasAudioRecording = false;
  String? _audioFilePath;
  String? _audioFileName;
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTicker;
  final AudioRecorder _audioRecorder = AudioRecorder();

  double _priorityValue = 1;

  bool get _isEditMode => widget.editingIssue != null;
  bool get _canEditSubmittedIssue =>
      !_isEditMode || widget.editingIssue!.status == ReportStatus.submitted;

  @override
  void initState() {
    super.initState();
    final issue = widget.editingIssue;
    if (issue == null) {
      return;
    }

    _selectedCategories
      ..clear()
      ..addAll(
        issue.category
            .split('•')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map(_toTitleCase),
      );

    _useAudioDescription = issue.hasAudioDescription;
    _audioFilePath = issue.audioPath ?? _firstAudioPath(issue.attachedMedia);
    _audioFileName = _audioFilePath?.split(RegExp(r'[\\/]')).last;
    _hasAudioRecording = issue.hasAudioDescription && (_audioFilePath?.isNotEmpty == true);
    _isAnonymous = issue.isAnonymous;
    _addressController.text = issue.address;
    _priorityValue = _priorityFromLabel(issue.priorityLabel);

    if (!issue.hasAudioDescription) {
      _descriptionController.text = issue.description.split('\n').first.trim();
    }

    _attachedMedia
      ..clear()
      ..addAll(
        issue.attachedMedia.where((path) => !_isAudioPath(path)).map((path) {
          final isVideo = _isVideoPath(path);
          final fileName = path.split(RegExp(r'[\\/]')).last;
          return _AttachedMedia(
            type: isVideo ? _MediaType.video : _MediaType.picture,
            label: fileName,
            path: path,
          );
        }),
      );
  }

  @override
  void dispose() {
    _recordingTicker?.cancel();
    _audioRecorder.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Update Issue' : 'Report Issue'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            children: [
              _buildSectionTitle('1. Select problem category'),
              const SizedBox(height: 10),
              if (_isEditMode && !_canEditSubmittedIssue) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Text(
                    'This issue can no longer be updated because it is already in review.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
              _buildCategorySelector(),
              const SizedBox(height: 22),
              _buildSectionTitle('2. Describe problem (text or audio)'),
              const SizedBox(height: 10),
              _buildDescriptionModeSelector(),
              const SizedBox(height: 10),
              _useAudioDescription
                  ? _buildAudioRecorderCard()
                  : _buildDescriptionTextField(),
              const SizedBox(height: 22),
              _buildSectionTitle('3. Problem address'),
              const SizedBox(height: 10),
              _buildAddressField(),
              const SizedBox(height: 22),
              _buildSectionTitle('4. Add supporting media'),
              const SizedBox(height: 10),
              _buildMediaSection(),
              const SizedBox(height: 22),
              _buildSectionTitle('5. Priority level'),
              const SizedBox(height: 10),
              _buildPrioritySlider(),
              const SizedBox(height: 22),
              _buildSectionTitle('6. Privacy'),
              const SizedBox(height: 10),
              _buildAnonymousSwitch(),
              const SizedBox(height: 30),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: AppTextStyles.h4);
  }

  Widget _buildCategorySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allCategories.map((category) {
          final selected = _selectedCategories.contains(category);
          return FilterChip(
            selected: selected,
            label: Text(category),
            selectedColor: AppColors.primaryBlueLight.withOpacity(0.2),
            checkmarkColor: AppColors.primaryBlue,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              color: selected ? AppColors.primaryBlueDark : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: selected ? AppColors.primaryBlue : AppColors.inputBorder,
            ),
            onSelected: (isSelected) {
              if (!_canEditSubmittedIssue) {
                return;
              }
              setState(() {
                if (isSelected) {
                  _selectedCategories.add(category);
                } else {
                  _selectedCategories.remove(category);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionModeSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            selected: !_useAudioDescription,
            label: const Text('Write Description'),
            onSelected: (_) {
              if (!_canEditSubmittedIssue) {
                return;
              }
              setState(() {
                _useAudioDescription = false;
                _isRecordingAudio = false;
                _recordingTicker?.cancel();
                _hasAudioRecording = false;
                _audioFilePath = null;
                _audioFileName = null;
                _recordingDuration = Duration.zero;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ChoiceChip(
            selected: _useAudioDescription,
            label: const Text('Record Audio'),
            onSelected: (_) {
              if (!_canEditSubmittedIssue) {
                return;
              }
              setState(() {
                _useAudioDescription = true;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      controller: _descriptionController,
      enabled: _canEditSubmittedIssue,
      minLines: 4,
      maxLines: 6,
      style: AppTextStyles.inputText,
      decoration: _inputDecoration(
        hintText: 'Describe what happened, its impact, and any urgent details.',
      ),
      validator: (_) {
        if (_useAudioDescription) {
          return null;
        }

        if (_descriptionController.text.trim().isEmpty) {
          return 'Please describe the problem.';
        }

        return null;
      },
    );
  }

  Widget _buildAudioRecorderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isRecordingAudio ? Icons.mic : Icons.audiotrack,
                color: _isRecordingAudio ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isRecordingAudio
                      ? 'Recording... ${_formatDuration(_recordingDuration)}'
                      : _hasAudioRecording
                      ? 'Audio recorded: ${_audioFileName ?? 'voice_note.m4a'}'
                      : 'No audio recorded yet',
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _canEditSubmittedIssue && !_isRecordingAudio
                      ? _startAudioRecording
                      : null,
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const Text('Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textWhite,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canEditSubmittedIssue
                      ? (_isRecordingAudio
                          ? _stopAudioRecording
                          : _hasAudioRecording
                              ? () {
                                  setState(() {
                                    _hasAudioRecording = false;
                                    _audioFilePath = null;
                                    _audioFileName = null;
                                    _recordingDuration = Duration.zero;
                                  });
                                }
                              : null)
                      : null,
                  icon: Icon(_isRecordingAudio ? Icons.stop : Icons.delete_outline),
                  label: Text(_isRecordingAudio ? 'Stop' : 'Remove'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Record audio directly. It will be uploaded and shared with admin.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      enabled: _canEditSubmittedIssue,
      style: AppTextStyles.inputText,
      decoration: _inputDecoration(
        hintText: 'Enter address or nearby landmark of the issue.',
        prefixIcon: const Icon(Icons.place_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Address is required.';
        }

        return null;
      },
    );
  }

  Widget _buildMediaSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canEditSubmittedIssue
                      ? () => _pickMedia(type: _MediaType.picture)
                      : null,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Add Image'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canEditSubmittedIssue
                      ? () => _pickMedia(type: _MediaType.video)
                      : null,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text('Add Video'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_attachedMedia.isEmpty)
            Text('No media attached yet.', style: AppTextStyles.caption)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _attachedMedia.map((media) {
                return Chip(
                  avatar: Icon(
                    media.type == _MediaType.picture
                        ? Icons.image
                        : Icons.videocam,
                    size: 16,
                  ),
                  label: Text(media.label),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    if (!_canEditSubmittedIssue) {
                      return;
                    }
                    setState(() {
                      _attachedMedia.remove(media);
                    });
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPrioritySlider() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Slider(
            value: _priorityValue,
            min: 1,
            max: 3,
            divisions: 2,
            label: _priorityLabel,
            onChanged: (value) {
              if (!_canEditSubmittedIssue) {
                return;
              }
              setState(() {
                _priorityValue = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [Text('Low'), Text('Medium'), Text('High')],
          ),
          const SizedBox(height: 6),
          Text('Selected priority: $_priorityLabel', style: AppTextStyles.captionBold),
        ],
      ),
    );
  }

  Widget _buildAnonymousSwitch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: SwitchListTile(
        value: _isAnonymous,
        contentPadding: EdgeInsets.zero,
        title: Text('Report anonymously', style: AppTextStyles.bodyMedium),
        subtitle: Text(
          _isAnonymous
              ? 'Your identity will be hidden from public view.'
              : 'Your profile can be shown for follow-up communication.',
          style: AppTextStyles.caption,
        ),
        onChanged: (value) {
          if (!_canEditSubmittedIssue) {
            return;
          }
          setState(() {
            _isAnonymous = value;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting || !_canEditSubmittedIssue
            ? null
            : () => _submitReport(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Text(
                _isEditMode ? 'Update Issue' : 'Submit Issue',
                style: AppTextStyles.button,
              ),
      ),
    );
  }

  Future<void> _submitReport(BuildContext context) async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_useAudioDescription && (_audioFilePath == null || _audioFilePath!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record an audio description.')),
      );
      return;
    }

    if (_isRecordingAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please stop recording before submitting.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    if (_isEditMode) {
      final updated = await context.read<CitizenHomeProvider>().updateSubmittedIssue(
        issueId: widget.editingIssue!.id,
        categories: _selectedCategories.toList(),
        description:
            _useAudioDescription ? null : _descriptionController.text.trim(),
        hasAudioDescription: _useAudioDescription,
        audioPath: _audioFilePath,
        address: _addressController.text.trim(),
        attachedMedia: _attachedMedia.map((media) => media.path).toList(),
        priorityLabel: _priorityLabel,
        isAnonymous: _isAnonymous,
      );

      if (!updated && mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Issue cannot be updated because it is already in review.',
            ),
          ),
        );
        return;
      }
    } else {
      final submittedReport = await context.read<CitizenHomeProvider>().submitIssue(
        categories: _selectedCategories.toList(),
        description:
            _useAudioDescription ? null : _descriptionController.text.trim(),
        hasAudioDescription: _useAudioDescription,
        audioPath: _audioFilePath,
        address: _addressController.text.trim(),
        attachedMedia: _attachedMedia.map((media) => media.path).toList(),
        priorityLabel: _priorityLabel,
        isAnonymous: _isAnonymous,
      );

      if (submittedReport == null && mounted) {
        final errorText = context.read<CitizenHomeProvider>().errorMessage;
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText ?? 'Could not submit issue. Please retry.'),
          ),
        );
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportConfirmationScreen(
            trackingId: submittedReport!.id,
            category: _selectedCategories.join(' • '),
            location: _addressController.text.trim(),
            priority: _priorityLabel,
            isAnonymous: _isAnonymous,
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (_isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue updated successfully.')),
      );
      Navigator.of(context).pop();
    }
  }

  InputDecoration _inputDecoration({String? hintText, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.inputHint,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.backgroundWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.4),
      ),
    );
  }

  Future<void> _startAudioRecording() async {
    try {
      if (_requiresMicrophonePermission()) {
        var hasPermission = false;
        try {
          hasPermission = await _audioRecorder.hasPermission();
        } on MissingPluginException {
          // Some targets/plugins do not expose explicit permission APIs.
          hasPermission = true;
        }

        if (!hasPermission) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required.')),
          );
          return;
        }
      }

      final encoder = _recordEncoderForPlatform();
      final extension = _recordExtensionForEncoder(encoder);
        final filePath = kIsWeb
          ? 'report_audio_${DateTime.now().millisecondsSinceEpoch}.$extension'
          : '${(await getTemporaryDirectory()).path}/report_audio_${DateTime.now().millisecondsSinceEpoch}.$extension';

      final config = RecordConfig(
        encoder: encoder,
        bitRate: 128000,
        sampleRate: 44100,
      );

      try {
        await _audioRecorder.start(config, path: filePath);
      } catch (_) {
        // Fallback for platforms/devices with limited encoder support.
        await _audioRecorder.start(const RecordConfig(), path: filePath);
      }

      _recordingTicker?.cancel();
      _recordingTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isRecordingAudio) {
          timer.cancel();
          return;
        }
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      });

      setState(() {
        _isRecordingAudio = true;
        _recordingDuration = Duration.zero;
      });
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Audio recording is not available on this run target. Run on Android or iOS device/emulator.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start audio recording: $error')),
      );
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      _recordingTicker?.cancel();
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecordingAudio = false;
        _audioFilePath = path;
        _audioFileName = path?.split(RegExp(r'[\\/]')).last;
        _hasAudioRecording = path != null && path.isNotEmpty;
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _isRecordingAudio = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Audio recording is not available on this run target. Run on Android or iOS device/emulator.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isRecordingAudio = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not stop audio recording.')),
      );
    }
  }

  Future<void> _pickMedia({required _MediaType type}) async {
    try {
      final group = XTypeGroup(
        label: type == _MediaType.picture ? 'images' : 'videos',
        extensions: type == _MediaType.picture
            ? const ['jpg', 'jpeg', 'png', 'gif', 'webp']
            : const ['mp4', 'mov', 'avi', 'mkv', 'webm'],
      );

      final selectedFiles = await openFiles(
        acceptedTypeGroups: [group],
        confirmButtonText:
            type == _MediaType.picture ? 'Select image' : 'Select video',
      );

      if (selectedFiles.isEmpty) {
        return;
      }

      final pending = <_AttachedMedia>[];

      for (final selectedFile in selectedFiles) {
        String resolvedPath;

        if (selectedFile.path.isNotEmpty) {
          resolvedPath = selectedFile.path;
        } else {
          final bytes = await selectedFile.readAsBytes();
          if (bytes.isEmpty) {
            continue;
          }

          final mimeType = type == _MediaType.picture ? 'image/jpeg' : 'video/mp4';
          resolvedPath = 'data:$mimeType;base64,${base64Encode(bytes)}';
        }

        pending.add(
          _AttachedMedia(
            type: type,
            label: selectedFile.name,
            path: resolvedPath,
          ),
        );
      }

      if (pending.isEmpty) {
        return;
      }

      setState(() {
        _attachedMedia.addAll(pending);
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${pending.length} file(s) added.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open file explorer: ${error.toString()}',
          ),
        ),
      );
    }
  }

  bool _isVideoPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }

  bool _isAudioPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.aac') ||
        lower.endsWith('.ogg');
  }

  String? _firstAudioPath(List<String> mediaPaths) {
    for (final path in mediaPaths) {
      if (_isAudioPath(path)) {
        return path;
      }
    }
    return null;
  }

  String _toTitleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    final lower = value.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  double _priorityFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      default:
        return 1;
    }
  }

  String get _priorityLabel {
    final value = _priorityValue.round();
    if (value <= 1) {
      return 'Low';
    }
    if (value == 2) {
      return 'Medium';
    }
    return 'High';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  AudioEncoder _recordEncoderForPlatform() {
    if (kIsWeb) {
      return AudioEncoder.opus;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return AudioEncoder.aacLc;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return AudioEncoder.wav;
    }
  }

  bool _requiresMicrophonePermission() {
    if (kIsWeb) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  String _recordExtensionForEncoder(AudioEncoder encoder) {
    switch (encoder) {
      case AudioEncoder.wav:
        return 'wav';
      case AudioEncoder.opus:
        return 'webm';
      case AudioEncoder.aacLc:
      case AudioEncoder.aacEld:
      case AudioEncoder.aacHe:
      case AudioEncoder.amrNb:
      case AudioEncoder.amrWb:
      case AudioEncoder.flac:
      case AudioEncoder.pcm16bits:
        return 'm4a';
    }
  }

}

enum _MediaType { picture, video }

class _AttachedMedia {
  final _MediaType type;
  final String label;
  final String path;

  const _AttachedMedia({
    required this.type,
    required this.label,
    required this.path,
  });
}
