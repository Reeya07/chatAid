import 'package:flutter/material.dart';
import 'package:mental_health_app/controllers/cbt_controller.dart';
import '../utils/thinking_pattern_detector.dart';

class CbtScreen extends StatefulWidget {
  const CbtScreen({super.key});

  @override
  State<CbtScreen> createState() => CbtScreenState();
}

class CbtScreenState extends State<CbtScreen> {
  final TextEditingController situationC = TextEditingController();
  final TextEditingController thoughtC = TextEditingController();
  final TextEditingController evidenceC = TextEditingController();
  final TextEditingController adviceC = TextEditingController();
  final CbtController cbt = CbtController();

  bool _loading = false;
  String balancedText = "";
  double before = 3;
  double after = 3;
  bool showAfter = false;

  String _selectedPattern = "Unclear"; //to be auto suggested by algorithm

  final Map<String, String> patterns = {
    "Unclear": "Not sure",
    "All or Nothing thinking": "Black and white",
    "Catastrophizing": "Worst-case",
    "Mind Reading": "Assuming",
    "Overgeneralization": "Always/Everyone",
    "Should statements": "Should/Must",
    "Personalization": "My fault",
  };
  final Map<String, String> patternExplain = {
    "Unclear": "You can skip this",
    "All or Nothing thinking": "2 options: perfect or fail",
    "Catastrophizing": "Jumping to worst case scenario",
    "Mind Reading": "Guessing what others think",
    "Overgeneralization": "One time= always happen",
    "Should statements": "Putting pressure with should/must",
    "Personalization": "Blaming myself too much",
  };

  @override
  void dispose() {
    situationC.dispose();
    thoughtC.dispose();
    evidenceC.dispose();
    adviceC.dispose();
    super.dispose();
  }

  void showPattern() {
    final String title = patterns[_selectedPattern] ?? _selectedPattern;
    final String msg = patternExplain[_selectedPattern] ?? "";
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(msg),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget card({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //if pass chat later
    //final args = ModalRoute.of(context)?.setting.arguments as Map?;
    //if(args != null && thoughtC.text.isEmpty) thoughtC.text= args['initual Thought']??"";

    return Scaffold(
      backgroundColor: Color(0xFFE9E3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          "CBT Thought Record",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          card(
            title: "1) What happened?(Situation)",
            child: TextField(
              controller: situationC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Example:I have an exam tomorrow...",
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "2) What thought popped up?",
            child: TextField(
              controller: thoughtC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Example:I'am going to fail and ruin everything.",
                border: InputBorder.none,
              ),
              onChanged: (text) {
                final result = detectPattern(text);

                if (result.confidence >= 0.8) {
                  setState(() {
                    _selectedPattern = result.label;
                  });
                }
              },
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "3) How intense does it feel right now",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Intensity: ${before.round()}/5"),
                Slider(
                  value: before,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: before.round().toString(),
                  onChanged: (v) => setState(() => before = v),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "4) Possible thnking patterns",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "This is just a suggestion-you can change it.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: patterns.entries.map((e) {
                    final key = e.key;
                    final label = e.value;

                    final bool selected = _selectedPattern == key;

                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedPattern = key);
                        showPattern();
                      },
                      selectedColor: Color(0xFF7B5BBE),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: Color(0XFFF4F2FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: BorderSide(color: Colors.black12),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "5) What makes it feel true?",
            child: TextField(
              controller: evidenceC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "A few fact you are focusing on...",
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "6) What's a different perspective?",
            child: TextField(
              controller: adviceC,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What would you tell a friend?",
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 12),
          card(
            title: "7) Balanced Thought(next step)",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Next,we'll generate a kinder and more balanced way to say this.",
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() {
                            _loading = true;
                            showAfter = true;
                          });
                          try {
                            final result = await cbt.generateBalancedThought(
                              situation: situationC.text,
                              thought: thoughtC.text,
                              thinkingPattern: _selectedPattern,
                              evidenceFor: evidenceC.text,
                              advice: adviceC.text,
                            );
                            if (!context.mounted) return;
                            setState(() {
                              _loading = false;
                              balancedText = result;
                            });
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _loading = false);

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text("Error:$e")));
                          }
                        },
                  child: Text(
                    _loading ? "Generating..." : "Generate balanced thought",
                  ),
                ),
                if (balancedText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F2FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      balancedText,
                      style: const TextStyle(fontSize: 15, height: 1.3),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showAfter) ...[
            SizedBox(height: 12),
            card(
              title: "8) How intense does it feel now?",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Intensity:${after.round()}/5"),
                  Slider(
                    value: after,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: after.round().toString(),
                    onChanged: (v) => setState(() => after = v),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Summary:${before.round()}->${after.round()}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
