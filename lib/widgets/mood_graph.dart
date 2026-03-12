import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_log.dart';

class MoodGraph extends StatelessWidget {
  final List<MoodLog> moodLogs;

  final void Function(String exerciseKey)? onRecommendTap;

  const MoodGraph({super.key, required this.moodLogs, this.onRecommendTap});

  DateTime removeTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF4FC3F7);

  String day(DateTime dt) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[dt.weekday - 1];
  }

  String exerciseForScore(double score) {
    if (score <= 3.0) return "grounding";
    return "breathing";
  }

  String exerciseTitle(String key) {
    if (key == "grounding") return "Grounding exercise";
    return "Breathing exercise";
  }

  String friendlyMessage(String key, double weekAvg) {
    final scoreText = weekAvg.toStringAsFixed(1);

    if (key == "grounding") {
      return "I noticed this week has been a bit heavy for you (avg $scoreText) 💙 Let’s try a grounding exercise together.";
    } else {
      return "You’ve had a mixed week (avg $scoreText) 🌿 A short breathing exercise can help you reset.";
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final today = removeTime(DateTime.now());
    final firstDay = today.subtract(const Duration(days: 6));

    final Map<DateTime, List<int>> moodsPerDay = {};

    for (final log in moodLogs) {
      if (log.createdAt == null) continue;

      final logDay = removeTime(log.createdAt!.toDate());
      if (logDay.isBefore(firstDay) || logDay.isAfter(today)) continue;

      moodsPerDay.putIfAbsent(logDay, () => []).add(log.moodScore);
    }

    final sortedDays = moodsPerDay.keys.toList()..sort();

    final pointDates = <DateTime>[];
    final moodPoints = <FlSpot>[];

    for (int i = 0; i < sortedDays.length; i++) {
      final scores = moodsPerDay[sortedDays[i]]!;
      final avg = scores.last.toDouble();

      pointDates.add(sortedDays[i]);
      moodPoints.add(FlSpot(i.toDouble(), avg));
    }

    final weekAvg = moodPoints.isEmpty
        ? 0.0
        : moodPoints.map((e) => e.y).reduce((a, b) => a + b) /
              moodPoints.length;

    final recommendedKey = moodPoints.isEmpty
        ? "breathing"
        : exerciseForScore(weekAvg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mood trend(last 7 days)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (moodPoints.isEmpty)
          Container(
            height: 160,
            alignment: Alignment.center,
            child: const Text(
              "No mood entries in the last 7 days yet.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (moodPoints.length - 1).toDouble(),
                minY: 1,
                maxY: 5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: secondary.withOpacity(0.18),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        "Mood Score",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    axisNameSize: 22,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 18,
                      getTitlesWidget: (value, meta) {
                        final n = value.toInt();
                        if (n < 1 || n > 5) return const SizedBox.shrink();
                        return Text(
                          n.toString(),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Text(
                        "Day",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    axisNameSize: 24,
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= pointDates.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          day(pointDates[index]),
                          style: const TextStyle(fontSize: 11),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: moodPoints,
                    isCurved: true,
                    barWidth: 3,
                    color: primary,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          secondary.withOpacity(0.45),
                          secondary.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (moodPoints.length == 1)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              "Log mood for at least 2 days to see a trend line.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text("A little support for you"),
            subtitle: Text(
              moodPoints.isEmpty
                  ? "Start logging your mood to see your weekly trend 💙"
                  : friendlyMessage(recommendedKey, weekAvg),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onRecommendTap?.call(recommendedKey),
          ),
        ),
      ],
    );
  }
}
