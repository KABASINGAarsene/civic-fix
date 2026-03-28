import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CaseVerificationScreen extends StatefulWidget {
  const CaseVerificationScreen({Key? key}) : super(key: key);

  @override
  State<CaseVerificationScreen> createState() => _CaseVerificationScreenState();
}

class _CaseVerificationScreenState extends State<CaseVerificationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _ticketId;
  bool _isAdmin = false;
  String? _citizenName;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _ticketId = args?['ticketId'];
    _isAdmin = args?['isAdmin'] ?? false;
    
    // In a real app, we'd fetch these from the Chat metadata doc if not provided
    _citizenName = args?['citizenName'] ?? 'Citizen';

    if (_ticketId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Error: No Ticket ID provided')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_ticketId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  reverse: true, // Show latest at bottom
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildMessageBubble(data);
                  },
                );
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: scheme.onSurface,
          size: 18,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            _isAdmin ? 'Citizen: $_citizenName' : 'District Official',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ticket: ${_ticketId!.substring(0, 8).toUpperCase()}',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.info_outline,
            color: scheme.primary,
          ),
          onPressed: () {
            // Navigate to actual ticket detail
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: scheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation...',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final scheme = Theme.of(context).colorScheme;
    final senderId = data['senderId'];
    final receiverId = data['receiverId'];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    // Determine who sent the message based on receiverId to fix the UI issue
    // when testing on the same browser (which shares the same FirebaseAuth currentUser).
    bool isMe;
    if (receiverId != null) {
      bool isSentByAdmin = receiverId != 'admin';
      isMe = _isAdmin ? isSentByAdmin : !isSentByAdmin;
    } else {
      isMe = senderId == currentUserId;
    }

    final type = data['type'] ?? 'text';
    final text = data['text'] ?? '';
    final attachmentUrl = data['attachmentUrl'];
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('jm').format(timestamp) : '';

    if (type == 'status_update') {
      return _buildSystemMessage(text, timeStr);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: scheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? scheme.primary : scheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      if (!isMe)
                        BoxShadow(
                          color: scheme.shadow.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (type == 'image' && attachmentUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              attachmentUrl,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                              },
                            ),
                          ),
                        ),
                      Text(
                        text,
                        style: TextStyle(
                          color: isMe ? scheme.onPrimary : scheme.onSurface,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSystemMessage(String text, String time) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, color: scheme.primary, size: 16),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: scheme.outline.withValues(alpha: 0.45),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: scheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _ticketId == null) return;

    _messageController.clear();

    try {
      final chatRef = FirebaseFirestore.instance.collection('chats').doc(_ticketId);
      
      // 1. Add message
      await chatRef.collection('messages').add({
        'senderId': user.uid,
        'receiverId': _isAdmin ? 'citizen' : 'admin', // placeholder for now
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'text',
      });

      // 2. Update metadata
      await chatRef.update({
        'lastMessage': text,
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }
}
