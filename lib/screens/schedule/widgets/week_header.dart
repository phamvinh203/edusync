import 'package:flutter/material.dart';

class WeekHeader extends StatelessWidget {
  final DateTime weekStart;
  final VoidCallback onPrevWeek;
  final VoidCallback onNextWeek;

  const WeekHeader({
    super.key,
    required this.weekStart,
    required this.onPrevWeek,
    required this.onNextWeek,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final weekDays = List<DateTime>.generate(
      7,
      (i) => weekStart.add(Duration(days: i)),
    );
    String formatDate(DateTime d) => '${d.day}/${d.month}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevWeek,
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    weekDays.map((d) {
                      final isToday = _isSameDay(d, DateTime.now());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            Text(
                              [
                                'T2',
                                'T3',
                                'T4',
                                'T5',
                                'T6',
                                'T7',
                                'CN',
                              ][d.weekday - 1],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isToday ? Colors.blue : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isToday
                                        ? Colors.blue.withOpacity(0.1)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    isToday
                                        ? Border.all(color: Colors.blue)
                                        : null,
                              ),
                              child: Text(
                                formatDate(d),
                                style: TextStyle(
                                  color: isToday ? Colors.blue : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNextWeek,
          ),
        ],
      ),
    );
  }
}
