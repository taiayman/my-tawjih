import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taleb_edu_platform/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:taleb_edu_platform/screens/signin_screen.dart';

class SupportScreen extends ConsumerStatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _userId;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _listenForNewMessages();
    _setupConnectivity();
    _messageController.addListener(_onTypingChanged);
  }

  void _setupConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  void _onTypingChanged() {
    if (_messageController.text.isNotEmpty) {
      if (!_isTyping) {
        setState(() => _isTyping = true);
        _firestore.collection('user_states').doc(_userId).set({'isTyping': true});
      }
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(seconds: 2), () {
        setState(() => _isTyping = false);
        _firestore.collection('user_states').doc(_userId).set({'isTyping': false});
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _messageController.removeListener(_onTypingChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _listenForNewMessages();
    }
  }

  void _listenForNewMessages() {
    _messageSubscription = _firestore
        .collection('support_messages')
        .where('userId', isEqualTo: _userId)
        .where('isAdminMessage', isEqualTo: true)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newMessage = change.doc.data() as Map<String, dynamic>;
          final messageContent = newMessage['content'] as String;
          // Handle new message notification if needed
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2196F3),
        title: Text(
          'support_chat'.tr(),
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFFFFF),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.wifi : Icons.wifi_off),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isOnline ? 'online'.tr() : 'offline'.tr())),
            ),
          ),
        ],
      ),
      body: authState.isAuthenticated
          ? _buildAuthenticatedContent()
          : _buildUnauthenticatedContent(),
    );
  }

  Widget _buildAuthenticatedContent() {
    return Column(
      children: [
        if (!_isOnline)
          Container(
            color: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'offline_message'.tr(),
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        Expanded(
          child: _buildMessageList(),
        ),
        _buildTypingIndicator(),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildUnauthenticatedContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 24),
            Text(
              'sign_in_to_access_support'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  },
              child: Text(
                'sign_in'.tr(),
                style: GoogleFonts.cairo(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('support_messages')
          .where('userId', isEqualTo: _userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('error'.tr() + ': ${snapshot.error}'));
        } else {
          final messages = snapshot.data!.docs;
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
          return ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: messages.length,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            itemBuilder: (context, index) {
              final messageData = messages[index].data() as Map<String, dynamic>;
              return _buildMessageBubble(messageData);
            },
          );
        }
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData) {
    final bool isUserMessage = !messageData['isAdminMessage'];
    final Timestamp? timestamp = messageData['timestamp'] as Timestamp?;
    final messageContent = messageData['content'] ?? '';

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUserMessage ? Color(0xFF2196F3) : Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              messageContent,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: isUserMessage ? Color(0xFFFFFFFF) : Color(0xFF212121),
              ),
            ),
            SizedBox(height: 4),
            Text(
              timestamp != null
                  ? DateFormat('HH:mm').format(timestamp.toDate())
                  : 'time_not_available'.tr(),
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isUserMessage ? Color(0xB3FFFFFF) : Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('user_states').doc('admin').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final isAdminTyping = snapshot.data!.get('isTyping') ?? false;
          if (isAdminTyping) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'admin_typing'.tr(),
                    style: GoogleFonts.cairo(
                      color: Color(0xFF757575),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.cairo(color: Color(0xFF212121)),
              decoration: InputDecoration(
                hintText: 'type_message'.tr(),
                hintStyle: GoogleFonts.cairo(color: Color(0xFF9E9E9E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFFF0F0F0),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            child: Icon(Icons.send, color: Color(0xFFFFFFFF)),
            backgroundColor: Color(0xFF2196F3),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      final newMessage = {
        'content': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isAdminMessage': false,
        'userId': _userId,
        'read': false,
      };

      try {
        await _firestore.collection('support_messages').add(newMessage);
        _messageController.clear();
        Future.delayed(Duration(milliseconds: 100), _scrollToBottom);
      } catch (e) {
        print('Error sending message: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_send_message'.tr())),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}