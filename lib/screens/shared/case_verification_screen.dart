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
      backgroundColor: _isAdmin ? const Color(0xFF111827) : const Color(0xFFF8F9FA),
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
    return AppBar(
      backgroundColor: _isAdmin ? const Color(0xFF1F2937) : const Color(0xFFF8F9FA),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: _isAdmin ? Colors.white : const Color(0xFF111827), size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            _isAdmin ? 'Citizen: $_citizenName' : 'District Official',
            style: TextStyle(
              color: _isAdmin ? Colors.white : const Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ticket: ${_ticketId!.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: _isAdmin ? Colors.white : const Color(0xFF0A4DDE)),
          onPressed: () {
            // Navigate to actual ticket detail
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: _isAdmin ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Start the conversation...',
            style: TextStyle(
              color: _isAdmin ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final senderId = data['senderId'];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isMe = senderId == currentUserId;
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
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE5E7EB),
                child: Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? const Color(0xFF2563EB) 
                        : (_isAdmin ? const Color(0xFF374151) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      if (!isMe && !_isAdmin)
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
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
                          color: isMe || _isAdmin ? Colors.white : const Color(0xFF111827),
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
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isAdmin ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isAdmin ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 16),
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
                      color: _isAdmin ? Colors.white : const Color(0xFF111827),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAdmin ? const Color(0xFF1F2937) : Colors.white,
        border: Border(top: BorderSide(color: _isAdmin ? const Color(0xFF374151) : const Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _isAdmin ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(color: _isAdmin ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: _isAdmin ? const Color(0xFF9CA3AF) : Colors.grey),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
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
