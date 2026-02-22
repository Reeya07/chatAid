import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_log.dart';

class MoodGraph extends StatelessWidget {
  final List<MoodLog> moodLogs;

  // NEW: notify parent which exercise to open
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

  // NEW: map score -> 2 exercises only
  String exerciseForScore(double score) {
    // <=3 => grounding, >3 => breathing (simple + logical)
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
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime firstDay = removeTime(today.subtract(Duration(days: 6)));

    final Map<DateTime, List<int>> moodsPerDay = {};
    for (int i = 0; i < 7; i++) {
      final DateTime day = removeTime(firstDay.add(Duration(days: i)));
      moodsPerDay[day] = [];
    }
    for (final log in moodLogs) {
      if (log.createdAt == null) continue;

      final DateTime logDay = removeTime(log.createdAt!.toDate());
      if (moodsPerDay.containsKey(logDay)) {
        moodsPerDay[logDay]!.add(log.moodScore);
      }
    }
    final List<FlSpot> moodPoints = [];
    int dayIndex = 0;

    moodsPerDay.forEach((DateTime day, List<int> scores) {
      double averageMood = 3;
      if (scores.isNotEmpty) {
        final int total = scores.reduce((a, b) => a + b);
        averageMood = total / scores.length;
      }
      moodPoints.add(FlSpot(dayIndex.toDouble(), averageMood));
      dayIndex++;
    });
    final allScores = moodPoints.map((e) => e.y).toList();
    double weekAvg = 3;
    if (allScores.isNotEmpty) {
      weekAvg = allScores.reduce((a, b) => a + b) / allScores.length;
    }

    final recommendedKey = exerciseForScore(weekAvg);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mood trend(last 7 days)",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 1,
              maxY: 5,

              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: secondary.withOpacity(0.18), strokeWidth: 1),
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
                  axisNameWidget: Padding(
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
                      if (n < 1 || n > 5) return SizedBox.shrink();

                      return Text(n.toString(), style: TextStyle(fontSize: 11));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Padding(
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
                      if (index < 0 || index > 6) return SizedBox.shrink();
                      final dayIndex = firstDay.add(Duration(days: index));
                      return Text(
                        day(dayIndex),
                        style: TextStyle(fontSize: 11),
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
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
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
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: const Text("A little support for you"),
            subtitle: Text(friendlyMessage(recommendedKey, weekAvg)),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => onRecommendTap?.call(recommendedKey),
          ),
        ),
      ],
    );
  }
}
