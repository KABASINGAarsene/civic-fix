import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:district_direct/l10n/app_localizations.dart';

class IssueDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  final String docId;

  const IssueDetailScreen({Key? key, this.data, required this.docId}) : super(key: key);

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  Map<String, dynamic>? _currentData;
  bool _isFetching = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    if (_currentData == null) {
      _fetchIssueData();
    }

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _position = Duration.zero; });
    });
  }

  Future<void> _fetchIssueData() async {
    setState(() => _isFetching = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('issues').doc(widget.docId).get();
      if (doc.exists && mounted) {
        setState(() {
          _currentData = doc.data();
          _isFetching = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching: $e');
      if (mounted) setState(() => _isFetching = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _commentController.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _getStatusColor(String status, ColorScheme scheme) {
    switch (status.trim().toLowerCase()) {
      case 'submitted':
      case 'open':
        return scheme.primary;
      case 'received':
      case 'assigned':
      case 'field visit':
      case 'in progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return scheme.tertiary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  Future<void> _deleteReport() async {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReportTitle),
        content: Text(l10n.deleteReportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteReportTitle, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('issues').doc(widget.docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reportDeletedSuccess)));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.deleteReportTitle}: $e')));
      }
    }
  }

  Future<void> _addComment() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _commentController.text.trim().isEmpty) return;

    final text = _commentController.text.trim();
    _commentController.clear();

    try {
      // Add comment to subcollection
      await FirebaseFirestore.instance
          .collection('issues')
          .doc(widget.docId)
          .collection('comments')
          .add({
        'text': text,
        'uid': user.uid,
        'userName': user.displayName ?? l10n.citizenPrefix,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Increment count in parent document
      await FirebaseFirestore.instance
          .collection('issues')
          .doc(widget.docId)
          .update({
        'comment_count': FieldValue.increment(1),
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.comments}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_isFetching) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: scheme.primary)),
      );
    }
    
    final data = _currentData;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.issueDetailsTitle)),
        body: Center(child: Text(l10n.reportNotFound)),
      );
    }

    final String title   = data['title'] ?? data['description'] ?? l10n.noTitle;
    final String desc    = data['description'] ?? '';
    final String status  = data['status'] ?? 'Submitted';
    final String cat     = data['category'] ?? l10n.unknownLabel;
    final String dist    = data['district'] ?? l10n.unknownLabel;
    final String sec     = data['sector'] ?? l10n.unknownLabel;
    final String? photo  = data['photo_url'];
    final String? audio  = data['audio_url'];
    final ts             = data['timestamp'];
    final String dateStr = ts != null
      ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}' : l10n.recently;
    final String shortId = '#${widget.docId.substring(0, 8).toUpperCase()}';

    final bool isReceived = status == 'Received' || status == 'Assigned' || status == 'Field Visit' || status == 'Resolved';
    final bool isAssigned = status == 'Assigned' || status == 'Field Visit' || status == 'Resolved';
    final bool isFieldVisit = status == 'Field Visit' || status == 'Resolved';
    final bool isResolved = status == 'Resolved';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: photo != null ? 240 : 80,
            pinned: true,
            backgroundColor: scheme.surface,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: scheme.onSurface,
                  size: 18,
                ),
              ),
            ),
            title: Text(
              l10n.issueDetailsTitle,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: photo != null
                  ? Image.network(photo, fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, prog) => prog == null ? child
                          : Container(color: scheme.surfaceContainerHighest,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))))
                  : Container(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: scheme.outline,
                          size: 48,
                        ),
                      )),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + ticket ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status, scheme).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(status.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: _getStatusColor(status, scheme), letterSpacing: 0.8)),
                      ),
                      Text(
                        shortId,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.submittedOn} $dateStr',
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: scheme.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),

                  // ── Details ──
                  _sectionTitle(l10n.issueDetailsTitle),
                  const SizedBox(height: 12),
                  _row(Icons.category_outlined, l10n.categoryDistribution, cat),
                  _row(Icons.location_city_outlined, l10n.homeDistrict, dist),
                  _row(Icons.place_outlined, l10n.homeSector, sec),
                  if (desc.isNotEmpty) _row(Icons.notes_outlined, l10n.homeDetails, desc),

                  // ── Audio ──
                  if (audio != null) ...[
                    const SizedBox(height: 20),
                    Divider(color: scheme.outline.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    _sectionTitle(l10n.voiceNote),
                    const SizedBox(height: 12),
                    _buildAudioPlayer(audio),
                  ],

                  const SizedBox(height: 20),
                  Divider(color: scheme.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),

                  // ── Tracker ──
                  _sectionTitle(l10n.reportProgress),
                  const SizedBox(height: 16),
                   _step(l10n.submittedStatus, dateStr, true, false),
                   _step(l10n.receivedStatus, isReceived ? l10n.confirmedByDistrict : l10n.awaitingConfirmation, isReceived, false),
                   _step(l10n.assignedStatus, isAssigned ? l10n.fieldTeamDispatched : '', isAssigned, false),
                   _step(l10n.fieldVisitStatus, isFieldVisit ? l10n.teamOnSite : '', isFieldVisit, false),
                   _step(l10n.resolvedStatus, isResolved ? l10n.issueClosed : '', isResolved, true),

                  // ── Edit & Delete ──
                  if (status == 'Submitted' || status == 'Open') ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/capture-evidence',
                            arguments: {
                              'docId':           widget.docId,
                              'title':           data['title'] ?? '',
                              'description':     data['description'] ?? '',
                              'category':        data['category'] ?? 'Infrastructure',
                              'district':        data['district'],
                              'sector':          data['sector'],
                              'priority':        data['priority'] ?? 1,
                              'is_anonymous':    data['is_anonymous'] ?? false,
                              'photo_url':       data['photo_url'],
                              'audio_url':       data['audio_url'],
                              'manual_location': data['manual_location'] ?? '',
                            },
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l10n.editReport, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteReport,
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        label: Text(l10n.deleteReportTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/chats', arguments: {
                          'isAdmin': false,
                          'ticketId': widget.docId,
                          'ticketTitle': title,
                        });
                      },
                      icon: const Icon(Icons.chat_outlined, size: 18),
                      label: Text(l10n.messageDistrictOfficial, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.tertiary,
                        foregroundColor: scheme.onTertiary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Divider(color: scheme.outline.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  _sectionTitle(l10n.comments),
                  const SizedBox(height: 12),
                  
                  // Comments List
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('issues')
                        .doc(widget.docId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            l10n.noCommentsYet,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final cdata = docs[index].data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: scheme.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Text(cdata['userName'] ?? l10n.citizenPrefix,
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: scheme.onSurface)),
                                      const SizedBox(height: 2),
                                      Text(cdata['text'] ?? '',
                                          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: l10n.addCommentHint,
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addComment,
                        icon: Icon(Icons.send, color: scheme.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _sectionTitle(String text) => Text(text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface));

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
      ])),
    ]),
  );

  Widget _buildAudioPlayer(String url) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
    ),
    child: Row(children: [
      GestureDetector(
        onTap: () async {
          if (_isPlaying) {
            await _audioPlayer.pause();
          } else {
            await _audioPlayer.play(UrlSource(url));
          }
        },
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
          child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Theme.of(context).colorScheme.onPrimary, size: 24),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            thumbColor: Theme.of(context).colorScheme.primary,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.outline,
            overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: _duration.inSeconds > 0
                ? _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()) : 0,
            max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
            onChanged: (v) async => await _audioPlayer.seek(Duration(seconds: v.toInt())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmt(_position), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            Text(_fmt(_duration), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      ])),
    ]),
  );

  Widget _step(String title, String subtitle, bool done, bool isLast) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            border: Border.all(color: done ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 2),
          ),
          child: done ? Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary) : null,
        ),
        if (!isLast) Container(width: 2, height: 28, color: Theme.of(context).colorScheme.outline),
      ]),
      const SizedBox(width: 14),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14,
              fontWeight: done ? FontWeight.bold : FontWeight.w500,
              color: done ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant)),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      )),
    ],
  );
}
