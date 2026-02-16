import 'package:flutter/material.dart';
import 'package:mental_health_app/controllers/mood_controller.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_info.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final Color primaryPurple = Color(0xFF7C6AED);
  final Color lightPurple = Color(0xFFF3F0FF);

  final TextEditingController _textC = TextEditingController();
  final FocusNode focus = FocusNode();
  final List<Chatinfo> _messages = [
    Chatinfo(
      role: 'assistant',
      text:
          'Hello, I am here to support you on yout mental wellness journey.How are you feeling today?',
    ),
  ];

  final ChatController _chat = ChatController(baseUrl: 'http://127.0.0.1:3000');
  bool _sending = false;

  @override
  void dispose() {
    _textC.dispose();
    focus.dispose();
    super.dispose();
  }

  String userMessage() {
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'user') return _messages[i].text;
    }
    return "";
  }

  Widget quickAction({required String assistantText}) {
    final lasUser = userMessage();
    final thoughToUse = lasUser.isNotEmpty ? lasUser : assistantText;

    return Padding(
      padding: EdgeInsets.only(left: 30, right: 8, bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton(
            onPressed: () {
              FocusScope.of(context).requestFocus(focus);
            },
            child: Text("Continue chatting"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                'views/CbtScreen',
                arguments: {
                  'initialThought': thoughToUse,
                  //can add situation later:
                  //'initialSituation':'',
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: Text('Try CBT'),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Exercises coming soon")));
            },
            child: Text("Try Exercise"),
          ),
        ],
      ),
    );
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
      final result = await _chat.sendMessage(text);
      final reply = result['reply'].toString();

      await MoodController().tickChatUsed();

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
            Icon(Icons.smart_toy_outlined, color: primaryPurple),
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
              physics: BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                final isLast = index == _messages.length - 1;
                final showActions = !isUser && isLast && !_sending;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 6),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        size: 22,
                        color: primaryPurple,
                      ),
                    ),
                    Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),

                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? primaryPurple : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showActions) quickAction(assistantText: msg.text),
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
                        focusNode: focus,
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
                        color: primaryPurple,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.send, color: Colors.white),
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
