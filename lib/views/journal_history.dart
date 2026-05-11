import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/journal_controller.dart';
import '../models/journal_info.dart';

class JournalHistoryScreen extends StatefulWidget {
  const JournalHistoryScreen({super.key});

  @override
  State<JournalHistoryScreen> createState() => _JournalHistoryScreenState();
}

class _JournalHistoryScreenState extends State<JournalHistoryScreen> {
  // Controllers
  final JournalController journalController = JournalController();
  final TextEditingController searchController = TextEditingController();

  // Filters
  DateTime? selectedDate;

  // UI state
  int? expandedCardIndex;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  static const _months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];

  String formatDate(DateTime date) {
    return "${date.day} ${_months[date.month - 1]} ${date.year}";
  }

  // Helper: same day check
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: DateTime(today.year - 5, 1, 1),
      lastDate: DateTime(today.year + 1, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      selectedDate = DateTime(picked.year, picked.month, picked.day);
      expandedCardIndex = null;
    });
  }

  void clearAllFilters() {
    setState(() {
      searchController.clear();
      selectedDate = null;
      expandedCardIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // very light ocean
      appBar: AppBar(
        backgroundColor: const Color(0xFF4FC3F7), // soft blue
        elevation: 0,
        title: const Text(
          "Floating Thoughts",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FirebaseAuth.instance.currentUser?.isAnonymous == true
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: Color(0xFF4FC3F7),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sign up to view your journal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B66),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a free account to save and revisit your thoughts anytime.',
                      style: TextStyle(color: Color(0xFF0D3B66), height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        'views/register',
                      ),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            )
          : StreamBuilder<List<JournalLog>>(
        stream: journalController.streamAllJournalLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading thoughts: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final List<JournalLog> allEntries = snapshot.data ?? [];

          if (allEntries.isEmpty) {
            return const Center(
              child: Text(
                "No thoughts yet 🫧",

                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          // Sort newest first
          allEntries.sort((a, b) {
            final DateTime dateA =
                a.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime dateB =
                b.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dateB.compareTo(dateA);
          });

          final String searchText = searchController.text.trim().toLowerCase();

          final List<JournalLog> filteredEntries = allEntries.where((entry) {
            final DateTime? entryDate = entry.createdAt?.toDate();
            if (entryDate == null) return selectedDate == null;
            if (selectedDate != null && !isSameDay(entryDate, selectedDate!)) return false;
            if (searchText.isNotEmpty && !entry.text.toLowerCase().contains(searchText)) return false;
            return true;
          }).toList();

          return Column(
            children: [
              buildFilterBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    return buildEntryCard(filteredEntries[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // UI: Filter bar
  Widget buildFilterBar() {
    final String dateLabel = selectedDate == null
        ? "Filter by date"
        : formatDate(selectedDate!);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search your thoughts…",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(dateLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: clearAllFilters,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // UI: One entry card (tap expands inline)
  Widget buildEntryCard(JournalLog entry) {
    final DateTime? entryDate = entry.createdAt?.toDate();

    final String dateLine = entryDate == null
        ? ""
        : "${formatDate(entryDate)} • "
              "${entryDate.hour.toString().padLeft(2, '0')}:${entryDate.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateLine,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(
            entry.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
