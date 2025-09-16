import 'package:flutter/material.dart';
import 'package:edusync/screens/schedule/schedule_event.dart';
import 'package:edusync/screens/schedule/widgets/week_event_card.dart';

class WeekList extends StatelessWidget {
  final Map<DateTime, List<ScheduleEvent>> eventsByDay;
  final DateTime weekStart;
  final Color Function(String subject) subjectColor;

  const WeekList({
    super.key,
    required this.eventsByDay,
    required this.weekStart,
    required this.subjectColor,
  });

  @override
  Widget build(BuildContext context) {
    final days = List<DateTime>.generate(
      7,
      (i) => DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      ).add(Duration(days: i)),
    );
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: days.length,
      itemBuilder: (context, idx) {
        final day = days[idx];
        final events =
            eventsByDay[DateTime(day.year, day.month, day.day)] ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Row(
                children: [
                  Text(
                    [
                      'Thứ 2',
                      'Thứ 3',
                      'Thứ 4',
                      'Thứ 5',
                      'Thứ 6',
                      'Thứ 7',
                      'Chủ nhật',
                    ][day.weekday - 1],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${day.day}/${day.month})',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Không có lịch học',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...events
                  .map(
                    (e) => WeekEventCard(event: e, subjectColor: subjectColor),
                  )
                  .toList(),
          ],
        );
      },
    );
  }
}
