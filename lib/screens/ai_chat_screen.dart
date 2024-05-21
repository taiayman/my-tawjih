import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIChatScreen extends StatefulWidget {
  final bool isDarkTheme;

  AIChatScreen({required this.isDarkTheme});

  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<Map<String, dynamic>> fetchFirestoreData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch companies
    QuerySnapshot companySnapshot = await firestore.collection('companies').get();
    List<Map<String, dynamic>> companies = companySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Fetch CEOs
    QuerySnapshot ceoSnapshot = await firestore.collection('ceos').get();
    List<Map<String, dynamic>> ceos = ceoSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Fetch projects
    QuerySnapshot projectSnapshot = await firestore.collection('projects').get();
    List<Map<String, dynamic>> projects = projectSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    return {
      'companies': companies,
      'ceos': ceos,
      'projects': projects,
    };
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "content": message});
      _isLoading = true;
    });

    // Fetch Firestore data
    final firestoreData = await fetchFirestoreData();

    // Create a system message to include the context
    final contextMessage = {
      "role": "system",
      "content": "Context: Companies - ${firestoreData['companies']}, CEOs - ${firestoreData['ceos']}, Projects - ${firestoreData['projects']}"
    };

    final apiKey = 'sk-proj-zuC8iJMN0OAjBE2fdrvST3BlbkFJg6uJPDSNJzbwkzyQ0mri';
    final url = 'https://api.openai.com/v1/chat/completions';

    final payload = {
      "model": "gpt-3.5-turbo",
      "messages": [
        contextMessage,
        {"role": "user", "content": message}
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        setState(() {
          _messages.add({"role": "ai", "content": content});
        });
      } else {
        setState(() {
          _messages.add({"role": "error", "content": 'Error: ${response.statusCode}\n${response.body}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "error", "content": 'Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message['role'] == 'user';
    bool isAI = message['role'] == 'ai';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isUser ? const Color.fromARGB(255, 255, 255, 255) : (isAI ? const Color.fromARGB(255, 227, 227, 227) : Colors.red[100]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message['content'] ?? '',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: isUser ? const Color.fromARGB(255, 0, 0, 0) : (isAI ? Colors.black : Colors.red[900]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Chat',
          style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: Color(0xFFD97757),
        elevation: 0,
        // Remove the back button
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
              widget.isDarkTheme ? Color(0xFF2C2B28) : Color(0xFFF2F0E8),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter your question',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        ),
                        style: GoogleFonts.nunito(fontSize: 16),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Color(0xFFD97757),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
