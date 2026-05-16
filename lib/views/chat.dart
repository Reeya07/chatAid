import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_info.dart';
import '../controllers/progress_controller.dart';
import '../views/exercises.dart';
import '../views/emergency.dart';

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
  final ScrollController _scrollC = ScrollController();
  final List<Chatinfo> _messages = [
    Chatinfo(
      role: 'assistant',
      text:
          'Hello, I am here to support you on yout mental wellness journey.How are you feeling today?',
    ),
  ];

  final ChatController _chat = ChatController(
    baseUrl: 'https://chataid-backend.onrender.com',
  );
  bool _sending = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollC.hasClients) {
        _scrollC.animateTo(
          _scrollC.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
    _scrollToBottom();
    FocusScope.of(context).requestFocus(focus);
  }

  @override
  void dispose() {
    _textC.dispose();
    focus.dispose();
    _scrollC.dispose();
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

    final rec = _lastRec;
    final String recType = rec?['type']?.toString() ?? 'chat';
    final String recLabel = rec?['label']?.toString() ?? '💬 Continue chatting';
    final String recId = rec?['id']?.toString() ?? '';
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
        );
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
                  : "Quick journal prompt \nWrite what's on your mind right now.",
            ),
          );
        });
        FocusScope.of(context).requestFocus(focus);
        return;
      }

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
    final text = _textC.text.trim();
    if (text.isEmpty || _sending) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _messages.add(Chatinfo(role: 'user', text: text));
    });
    _textC.clear();
    _scrollToBottom();

    try {
      final result = await _chat.sendMessage(text);
      final isAnon = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;
      if (!isAnon) {
        await _progressC.markDone('chat');
      }
      final reply = result['reply'].toString();
      final rec = result['recommendation'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _messages.add(Chatinfo(role: 'assistant', text: reply));
        _lastRec = rec;
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _messages.length + (_sending ? 1 : 0);

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
              controller: _scrollC,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              physics: BouncingScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (_sending && index == itemCount - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 6),
                          child: Icon(
                            Icons.smart_toy_outlined,
                            size: 22,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const _TypingDots(),
                        ),
                      ],
                    ),
                  );
                }

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
                    if (!isUser)
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
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _sending ? primary.withOpacity(0.5) : primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primary),
                      ),
                      child: Icon(Icons.send, color: Colors.white),
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

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(
              0.25,
              1.0,
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                  radius: 3,
                  backgroundColor: Colors.black38,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
