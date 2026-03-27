import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Submitted':   return const Color(0xFF2563EB); // Blue
      case 'Received':    return const Color(0xFF7C3AED); // Purple
      case 'Assigned':    return const Color(0xFFF59E0B); // Amber
      case 'Field Visit': return const Color(0xFFD97706); // Orange
      case 'Resolved':    return const Color(0xFF10B981); // Green
      default:            return const Color(0xFF6B7280); // Gray
    }
  }

  Future<void> _deleteReport() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('issues').doc(widget.docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report deleted successfully.')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _addComment() async {
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
        'userName': user.displayName ?? 'Citizen',
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to comment: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))));
    }
    
    final data = _currentData;
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Issue Details')),
        body: const Center(child: Text('Report not found.')),
      );
    }

    final String title   = data['title'] ?? data['description'] ?? 'No title';
    final String desc    = data['description'] ?? '';
    final String status  = data['status'] ?? 'Submitted';
    final String cat     = data['category'] ?? 'Unknown';
    final String dist    = data['district'] ?? 'Unknown';
    final String sec     = data['sector'] ?? 'Unknown';
    final String? photo  = data['photo_url'];
    final String? audio  = data['audio_url'];
    final ts             = data['timestamp'];
    final String dateStr = ts != null
        ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}' : 'Recently';
    final String shortId = '#${widget.docId.substring(0, 8).toUpperCase()}';

    final bool isReceived = status == 'Received' || status == 'Assigned' || status == 'Field Visit' || status == 'Resolved';
    final bool isAssigned = status == 'Assigned' || status == 'Field Visit' || status == 'Resolved';
    final bool isFieldVisit = status == 'Field Visit' || status == 'Resolved';
    final bool isResolved = status == 'Resolved';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: photo != null ? 240 : 80,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF111827), size: 18),
              ),
            ),
            title: const Text('Issue Details', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: photo != null
                  ? Image.network(photo, fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, prog) => prog == null ? child
                          : Container(color: const Color(0xFFE5E7EB),
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2))))
                  : Container(color: const Color(0xFFF3F4F6),
                      child: const Center(child: Icon(Icons.image_not_supported, color: Color(0xFFD1D5DB), size: 48))),
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
                          color: _getStatusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(status.toUpperCase(),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                            color: _getStatusColor(status), letterSpacing: 0.8)),
                      ),
                      Text(shortId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text('Submitted on $dateStr', style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),

                  // ── Details ──
                  _sectionTitle('Issue Details'),
                  const SizedBox(height: 12),
                  _row(Icons.category_outlined, 'Category', cat),
                  _row(Icons.location_city_outlined, 'District', dist),
                  _row(Icons.place_outlined, 'Sector', sec),
                  if (desc.isNotEmpty) _row(Icons.notes_outlined, 'Description', desc),

                  // ── Audio ──
                  if (audio != null) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFF3F4F6)),
                    const SizedBox(height: 16),
                    _sectionTitle('Voice Note'),
                    const SizedBox(height: 12),
                    _buildAudioPlayer(audio),
                  ],

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),

                  // ── Tracker ──
                  _sectionTitle('Report Progress'),
                  const SizedBox(height: 16),
                   _step('Submitted', dateStr, true, false),
                   _step('Received', isReceived ? 'Confirmed by District' : 'Awaiting confirmation', isReceived, false),
                   _step('Assigned', isAssigned ? 'Field team dispatched' : '', isAssigned, false),
                   _step('Field Visit', isFieldVisit ? 'Team on location' : '', isFieldVisit, false),
                   _step('Resolved', isResolved ? 'Issue closed' : '', isResolved, true),

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
                        label: const Text('Edit Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
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
                        label: const Text('Delete Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
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
                      label: const Text('Message District Official', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 16),
                  _sectionTitle('Comments'),
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
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text('No comments yet. Be the first to comment!',
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
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
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  child: const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cdata['userName'] ?? 'Citizen',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                                      const SizedBox(height: 2),
                                      Text(cdata['text'] ?? '',
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
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
                            hintText: 'Add a comment...',
                            hintStyle: const TextStyle(fontSize: 13),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addComment,
                        icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)));

  Widget _row(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: const Color(0xFF6B7280)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, color: Color(0xFF111827), fontWeight: FontWeight.w500)),
      ])),
    ]),
  );

  Widget _buildAudioPlayer(String url) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB)),
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
          decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
          child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            thumbColor: const Color(0xFF2563EB),
            activeTrackColor: const Color(0xFF2563EB),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            overlayColor: const Color(0xFF2563EB).withOpacity(0.15),
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
            Text(_fmt(_position), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text(_fmt(_duration), style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
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
            color: done ? const Color(0xFF2563EB) : Colors.white,
            border: Border.all(color: done ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB), width: 2),
          ),
          child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
        ),
        if (!isLast) Container(width: 2, height: 28, color: const Color(0xFFE5E7EB)),
      ]),
      const SizedBox(width: 14),
      Expanded(child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 14,
              fontWeight: done ? FontWeight.bold : FontWeight.w500,
              color: done ? const Color(0xFF111827) : const Color(0xFF9CA3AF))),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        ]),
      )),
    ],
  );
}
