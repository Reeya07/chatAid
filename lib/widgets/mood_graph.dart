import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_log.dart';

class MoodGraph extends StatelessWidget {
  final List<MoodLog> moodLogs;

  const MoodGraph({super.key, required this.moodLogs});

  DateTime removeTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String day(DateTime dt) {
    const names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[dt.weekday - 1];
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

              gridData: FlGridData(show: false),
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
                    reservedSize: 1,
                    getTitlesWidget: (value, meta) {
                      final n = value.toInt();
                      if (n < 0 || n > 6) return SizedBox.shrink();

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
                  color: Colors.purple,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Color.fromRGBO(128, 0, 128, 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
