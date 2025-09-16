import 'package:flutter/material.dart';
import 'package:edusync/screens/schedule/schedule_event.dart';
import 'package:edusync/screens/schedule/widgets/week_event_card.dart';

class DayEventsList extends StatelessWidget {
  final DateTime day;
  final List<ScheduleEvent> events;
  final Color Function(String subject) subjectColor;

  const DayEventsList({
    super.key,
    required this.day,
    required this.events,
    required this.subjectColor,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có lịch học',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder:
          (context, index) =>
              WeekEventCard(event: events[index], subjectColor: subjectColor),
    );
  }
}
