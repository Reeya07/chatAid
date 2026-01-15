import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_info.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _textC = TextEditingController();
  final List<Chatinfo> _messages = [
    Chatinfo(
      role: 'assistant',
      text:
          'Hello, I am here to support you on yout mental wellness journey.How are you feeling today?',
    ),
  ];

  final ChatController _chat = ChatController(baseUrl: 'http://10.0.2.2:3000');
  bool _sending = false;

  @override
  void dispose() {
    _textC.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textC.text;
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(Chatinfo(role: 'user', text: text));
    });
    _textC.clear();
    try {
      final reply = await _chat.sendMessage(text);

      if (!mounted) return;
      setState(() {
        _messages.add(Chatinfo(role: 'assistant', text: reply));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9E3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: Colors.black),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mental Health Companion',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Always here to listen',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isUser) ...[
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.smart_toy_outlined, size: 22),
                      ),
                      SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: TextField(
                        controller: _textC,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: "Write something...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
