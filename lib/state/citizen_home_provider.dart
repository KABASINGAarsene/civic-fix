import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../models/dashboard_models.dart';

class CitizenHomeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // UI State

  int _selectedNavIndex = 0;
  int _selectedFilterIndex = 0;

  int get selectedNavIndex => _selectedNavIndex;
  int get selectedFilterIndex => _selectedFilterIndex;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    // TODO: Re-fetch feed filtered by district/sector/cell when index changes
    notifyListeners();
  }

  // Feed Data State

  List<ReportItem> _feedItems = [];
  List<ReportItem> _myReportedItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReportItem> get feedItems => _feedItems;
  List<ReportItem> get myReportedItems => _myReportedItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Call this from initState of the screen to load the feed.
  Future<void> loadFeed() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      _feedItems = snapshot.docs.map(_reportFromDoc).toList();

      final currentUid = _auth.currentUser?.uid ?? 'guest';
      _myReportedItems = snapshot.docs
          .where((doc) => doc.data()['reporterId'] == currentUid)
          .map(_reportFromDoc)
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load reports. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upvote a report locally and sync to Firestore.
  Future<void> upvoteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'likes': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _feedItems = _feedItems.map((item) {
        if (item.id != reportId) return item;
        return ReportItem(
          id: item.id,
          title: item.title,
          description: item.description,
          category: item.category,
          timeLocation: item.timeLocation,
          status: item.status,
          icon: item.icon,
          likes: item.likes + 1,
          comments: item.comments,
          address: item.address,
          priorityLabel: item.priorityLabel,
          isAnonymous: item.isAnonymous,
          hasAudioDescription: item.hasAudioDescription,
          audioPath: item.audioPath,
          attachedMedia: item.attachedMedia,
          assignedTo: item.assignedTo,
          createdAt: item.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();
    } catch (_) {
      _errorMessage = 'Could not register upvote. Please try again.';
    }
    notifyListeners();
  }

  /// Submit a new citizen issue and add it to the top of the local feed.
  Future<ReportItem?> submitIssue({
    required List<String> categories,
    String? description,
    required bool hasAudioDescription,
    String? audioPath,
    required String address,
    required List<String> attachedMedia,
    required String priorityLabel,
    required bool isAnonymous,
  }) async {
    final firstCategory = categories.isNotEmpty ? categories.first : 'General';
    final icon = _iconForCategory(firstCategory);
    final details = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Audio description attached by citizen.';

    final mediaSummary = attachedMedia.isEmpty
        ? 'No media attached'
        : '${attachedMedia.length} media attachment(s)';

    final identity = isAnonymous ? 'Anonymous' : 'Citizen';

    try {
      final uid = _auth.currentUser?.uid ?? 'guest';
      final now = DateTime.now();

      final docRef = await _firestore.collection('reports').add({
        'title': '$firstCategory issue reported',
        'description':
            '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
        'categories': categories,
        'category': categories.join(' • ').toUpperCase(),
        'address': address,
        'priorityLabel': priorityLabel,
        'status': 'submitted',
        'likes': 0,
        'comments': 0,
        'isAnonymous': isAnonymous,
        'hasAudioDescription': false,
        'audioPath': null,
        'attachedMedia': const <String>[],
        'assignedTo': null,
        'reporterId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final uploadedMedia = await _uploadMediaFiles(
        reportId: docRef.id,
        mediaPaths: attachedMedia,
      );

      final uploadedAudioPath = await _uploadAudioFile(
        reportId: docRef.id,
        audioPath: hasAudioDescription ? audioPath : null,
      );

      await docRef.update({
        'hasAudioDescription': uploadedAudioPath != null,
        'audioPath': uploadedAudioPath,
        'attachedMedia': uploadedMedia,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final report = ReportItem(
        id: docRef.id,
        title: '$firstCategory issue reported',
        description:
            '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
        category: categories.join(' • ').toUpperCase(),
        timeLocation: 'Just now • $address',
        status: ReportStatus.submitted,
        icon: icon,
        likes: 0,
        comments: 0,
        address: address,
        priorityLabel: priorityLabel,
        isAnonymous: isAnonymous,
        hasAudioDescription: uploadedAudioPath != null,
        audioPath: uploadedAudioPath,
        attachedMedia: uploadedMedia,
        createdAt: now,
        updatedAt: now,
      );

      _feedItems = [report, ..._feedItems];
      _myReportedItems = [report, ..._myReportedItems];
      notifyListeners();
      return report;
    } catch (e) {
      _errorMessage = 'Failed to submit issue. ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing citizen-submitted issue while it is still in Submitted status.
  Future<bool> updateSubmittedIssue({
    required String issueId,
    required List<String> categories,
    String? description,
    required bool hasAudioDescription,
    String? audioPath,
    required String address,
    required List<String> attachedMedia,
    required String priorityLabel,
    required bool isAnonymous,
  }) async {
    final index = _myReportedItems.indexWhere((item) => item.id == issueId);
    if (index == -1) {
      return false;
    }

    final existing = _myReportedItems[index];
    if (existing.status != ReportStatus.submitted) {
      return false;
    }

    final docRef = _firestore.collection('reports').doc(issueId);
    final latestDoc = await docRef.get();
    if (!latestDoc.exists) {
      return false;
    }

    final latestData = latestDoc.data() ?? <String, dynamic>{};
    final latestStatus = (latestData['status'] as String? ?? 'submitted');
    if (latestStatus != 'submitted') {
      return false;
    }

    final firstCategory = categories.isNotEmpty ? categories.first : 'General';
    final icon = _iconForCategory(firstCategory);
    final details = description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Audio description attached by citizen.';

    final mediaSummary = attachedMedia.isEmpty
        ? 'No media attached'
        : '${attachedMedia.length} media attachment(s)';

    final identity = isAnonymous ? 'Anonymous' : 'Citizen';

    final updated = ReportItem(
      id: existing.id,
      title: '$firstCategory issue reported',
      description:
          '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
      category: categories.join(' • ').toUpperCase(),
      timeLocation: 'Updated just now • $address',
      status: existing.status,
      icon: icon,
      likes: existing.likes,
      comments: existing.comments,
      address: address,
      priorityLabel: priorityLabel,
      isAnonymous: isAnonymous,
      hasAudioDescription: hasAudioDescription,
      audioPath: audioPath,
      attachedMedia: attachedMedia,
    );

    final uploadedMedia = await _uploadMediaFiles(
      reportId: issueId,
      mediaPaths: attachedMedia,
    );

    final uploadedAudioPath = await _uploadAudioFile(
      reportId: issueId,
      audioPath: hasAudioDescription ? audioPath : null,
    );

    await docRef.update({
      'title': '$firstCategory issue reported',
      'description':
          '$details\nPriority: $priorityLabel • $mediaSummary • Reporter: $identity${hasAudioDescription ? ' • Audio included' : ''}',
      'categories': categories,
      'category': categories.join(' • ').toUpperCase(),
      'address': address,
      'priorityLabel': priorityLabel,
      'isAnonymous': isAnonymous,
      'hasAudioDescription': uploadedAudioPath != null,
      'audioPath': uploadedAudioPath,
      'attachedMedia': uploadedMedia,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedWithUploads = ReportItem(
      id: updated.id,
      title: updated.title,
      description: updated.description,
      category: updated.category,
      timeLocation: updated.timeLocation,
      status: updated.status,
      icon: updated.icon,
      likes: updated.likes,
      comments: updated.comments,
      address: updated.address,
      priorityLabel: updated.priorityLabel,
      isAnonymous: updated.isAnonymous,
      hasAudioDescription: uploadedAudioPath != null,
      audioPath: uploadedAudioPath,
      attachedMedia: uploadedMedia,
      assignedTo: updated.assignedTo,
      createdAt: updated.createdAt,
      updatedAt: DateTime.now(),
    );

    _myReportedItems[index] = updatedWithUploads;

    final feedIndex = _feedItems.indexWhere((item) => item.id == issueId);
    if (feedIndex != -1) {
      _feedItems[feedIndex] = updatedWithUploads;
    }

    notifyListeners();
    return true;
  }

  ReportItem _reportFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final category = (data['category'] as String?) ?? 'GENERAL';
    final address = (data['address'] as String?) ?? 'Unknown location';
    final createdAtTs = data['createdAt'] as Timestamp?;
    final updatedAtTs = data['updatedAt'] as Timestamp?;

    return ReportItem(
      id: doc.id,
      title: (data['title'] as String?) ?? 'Issue report',
      description: (data['description'] as String?) ?? '',
      category: category,
      timeLocation: '${_timeAgo(createdAtTs?.toDate())} • $address',
      status: _statusFromString((data['status'] as String?) ?? 'submitted'),
      icon: _iconForCategory(category),
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      comments: (data['comments'] as num?)?.toInt() ?? 0,
      address: address,
      priorityLabel: (data['priorityLabel'] as String?) ?? 'Low',
      isAnonymous: (data['isAnonymous'] as bool?) ?? false,
      hasAudioDescription: (data['hasAudioDescription'] as bool?) ?? false,
        audioPath: (data['audioPath'] as String?),
      attachedMedia: (data['attachedMedia'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      assignedTo: (data['assignedTo'] as String?) ?? (data['assignedToId'] as String?),
      createdAt: createdAtTs?.toDate(),
      updatedAt: updatedAtTs?.toDate(),
    );
  }

  ReportStatus _statusFromString(String value) {
    switch (value) {
      case 'inReview':
        return ReportStatus.inReview;
      case 'inProgress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'reported':
        return ReportStatus.reported;
      case 'submitted':
      default:
        return ReportStatus.submitted;
    }
  }

  String _timeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'infrastructure':
        return Icons.construction;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'security':
        return Icons.security;
      case 'land':
        return Icons.landscape_outlined;
      case 'justice':
        return Icons.gavel_outlined;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Future<List<String>> _uploadMediaFiles({
    required String reportId,
    required List<String> mediaPaths,
  }) async {
    final uploaded = <String>[];

    for (var i = 0; i < mediaPaths.length; i++) {
      final path = mediaPaths[i];
      try {
        if (_isRemotePath(path)) {
          uploaded.add(path);
          continue;
        }

        final fileName = _safeFileName(path, fallback: 'media_$i.bin');
        final storagePath = 'reports/$reportId/media/$fileName';

        if (kIsWeb || _isDataUrl(path) || _isBlobUrl(path)) {
          final bytes = await _loadBytesFromPath(path);
          if (bytes == null || bytes.isEmpty) {
            continue;
          }
          final ref = _storage.ref(storagePath);
          await ref.putData(
            bytes,
            SettableMetadata(contentType: _contentTypeFromName(fileName)),
          );
          uploaded.add(await ref.getDownloadURL());
          continue;
        }

        final file = File(path);
        if (!file.existsSync()) {
          continue;
        }

        final ref = _storage.ref(storagePath);
        await ref.putFile(file);
        uploaded.add(await ref.getDownloadURL());
      } catch (_) {
        // Skip a single broken file without failing the whole report.
        continue;
      }
    }

    return uploaded;
  }

  Future<String?> _uploadAudioFile({
    required String reportId,
    String? audioPath,
  }) async {
    if (audioPath == null || audioPath.isEmpty) {
      return null;
    }

    if (_isRemotePath(audioPath)) {
      return audioPath;
    }

    final fileName = _safeFileName(audioPath, fallback: 'voice_note.m4a');
    final storagePath = 'reports/$reportId/audio/$fileName';

    if (kIsWeb || _isDataUrl(audioPath) || _isBlobUrl(audioPath)) {
      final bytes = await _loadBytesFromPath(audioPath);
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      final ref = _storage.ref(storagePath);
      await ref.putData(
        bytes,
        SettableMetadata(contentType: _contentTypeFromName(fileName)),
      );
      return ref.getDownloadURL();
    }

    final file = File(audioPath);
    if (!file.existsSync()) {
      return null;
    }

    final ref = _storage.ref(storagePath);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  bool _isRemotePath(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  bool _isDataUrl(String path) => path.startsWith('data:');

  bool _isBlobUrl(String path) => path.startsWith('blob:');

  Future<Uint8List?> _loadBytesFromPath(String path) async {
    try {
      if (_isDataUrl(path)) {
        final marker = 'base64,';
        final markerIndex = path.indexOf(marker);
        if (markerIndex == -1) {
          return null;
        }
        final encoded = path.substring(markerIndex + marker.length);
        return base64Decode(encoded);
      }

      final uri = Uri.tryParse(path);
      if (uri == null) {
        return null;
      }

      final response = await http.get(uri);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  String _safeFileName(String source, {required String fallback}) {
    final extracted = source.split(RegExp(r'[\\/]')).last.trim();
    if (extracted.isEmpty || extracted.contains(':') || extracted.startsWith('data:') || extracted.startsWith('blob:')) {
      return fallback;
    }
    return extracted;
  }

  String _contentTypeFromName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    if (lower.endsWith('.wav')) return 'audio/wav';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    if (lower.endsWith('.aac')) return 'audio/aac';
    if (lower.endsWith('.ogg')) return 'audio/ogg';
    return 'application/octet-stream';
  }

}
