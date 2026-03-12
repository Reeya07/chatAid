import 'package:flutter/material.dart';
import 'package:mental_health_app/controllers/mood_controller.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_info.dart';
import '../controllers/progress_controller.dart';
import '../views/exercises.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final Color primary = Color(0xFF1E88E5);
  final Color light = Color.fromARGB(255, 138, 187, 251);

  Map<String, dynamic>? _lastRec;
  final TextEditingController _textC = TextEditingController();
  final ProgressController _progressC = ProgressController();
  final FocusNode focus = FocusNode();
  final List<Chatinfo> _messages = [
    Chatinfo(
      role: 'assistant',
      text:
          'Hello, I am here to support you on yout mental wellness journey.How are you feeling today?',
    ),
  ];

  final ChatController _chat = ChatController(
    baseUrl: 'https://chataid-backend-production.up.railway.app',
  );
  bool _sending = false;

  Future<void> _openRecommendedExercise(String exerciseId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Exercises(initialExerciseKey: exerciseId),
      ),
    );

    if (!mounted) return;
    setState(() {
      _messages.add(
        Chatinfo(
          role: 'assistant',
          text: "Welcome back How are you feeling now?",
        ),
      );
    });

    FocusScope.of(context).requestFocus(focus);
  }

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
    final lastUser = userMessage();
    final thoughtToUse = lastUser.isNotEmpty ? lastUser : assistantText;

    final rec = _lastRec; // Map<String, dynamic>? stored from backend
    final String recType = rec?['type']?.toString() ?? 'chat';
    final String recLabel = rec?['label']?.toString() ?? '💬 Continue chatting';
    final String recId = rec?['id']?.toString() ?? ''; // breathing / grounding
    final String recThought = (rec?['initialThought']?.toString() ?? '').trim();
    final String journalPrompt = (rec?['journalPrompt']?.toString() ?? '')
        .trim();

    Future<void> handleRecommendation() async {
      if (recType == 'exercise') {
        final id = recId.isNotEmpty ? recId : 'breathing';
        await _openRecommendedExercise(id);
        return;
      }
      if (recType == 'support') {
        Navigator.pushNamed(context, 'views/emergency');
        return;
      }

      if (recType == 'cbt') {
        final thought = recThought.isNotEmpty ? recThought : thoughtToUse;
        Navigator.pushNamed(
          context,
          'views/CbtScreen',
          arguments: {'initialThought': thought},
        );
        return;
      }

      if (recType == 'journal') {
        Navigator.pushNamed(
          context,
          'views/journal',
          arguments: {'prompt': journalPrompt},
        );
        setState(() {
          _messages.add(
            Chatinfo(
              role: 'assistant',
              text: journalPrompt.isNotEmpty
                  ? "Quick journal prompt \n$journalPrompt"
                  : "Quick journal prompt \nWrite what’s on your mind right now.",
            ),
          );
        });
        FocusScope.of(context).requestFocus(focus);
        return;
      }

      // chat
      FocusScope.of(context).requestFocus(focus);
    }

    Widget chip({
      required String label,
      required VoidCallback onTap,
      bool filled = false,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primary.withOpacity(0.35)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // Small helper text so the “smartness” is visible
    final String hint = rec?['reason']?.toString() ?? "Suggested next step:";

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // ⭐ Recommended action (highlighted)
              chip(
                label: recLabel,
                filled: true,
                onTap: () async => await handleRecommendation(),
              ),

              chip(
                label: "🧠 Explore CBT",
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    'views/CbtScreen',
                    arguments: {'initialThought': thoughtToUse},
                  );
                },
              ),
              chip(
                label: "🌿 Exercises",
                onTap: () async {
                  // Opens list normally (no auto exercise)
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Exercises()),
                  );
                  if (!mounted) return;
                  FocusScope.of(context).requestFocus(focus);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _textC.text;
    if (text.isEmpty || _sending) return;

    await _progressC.markDone('chat');

    setState(() {
      _sending = true;
      _messages.add(Chatinfo(role: 'user', text: text));
    });
    _textC.clear();
    try {
      final result = await _chat.sendMessage(text);
      final reply = result['reply'].toString();
      final rec = result['recommendation'] as Map<String, dynamic>?;

      await MoodController().tickChatUsed();

      if (!mounted) return;
      setState(() {
        _messages.add(Chatinfo(role: 'assistant', text: reply));
        _lastRec = rec;
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
      backgroundColor: Color.fromARGB(255, 193, 223, 249),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // fallback if it's root
              Navigator.pushReplacementNamed(context, 'views/nav');
            }
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: primary),
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
                        color: primary,
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
                            color: isUser ? primary : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
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
                        color: primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primary),
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
