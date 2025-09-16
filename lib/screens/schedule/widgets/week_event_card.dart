import 'package:flutter/material.dart';
import 'package:edusync/screens/schedule/schedule_event.dart';

class WeekEventCard extends StatelessWidget {
  final ScheduleEvent event;
  final Color Function(String subject) subjectColor;
  final VoidCallback? onTap;

  const WeekEventCard({
    super.key,
    required this.event,
    required this.subjectColor,
    this.onTap,
  });

  String _formatTimeRange(String start, String end, String duration) {
    if (duration.isNotEmpty) return duration;
    if (start.isNotEmpty && end.isNotEmpty) return '$start - $end';
    return 'Chưa có thời gian';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: subjectColor(event.classSchedule.subject),
          child: Text(
            event.classSchedule.subject.isNotEmpty
                ? event.classSchedule.subject.substring(0, 1).toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          event.classSchedule.nameClass,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event.classSchedule.subject} - ${event.classSchedule.gradeLevel}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTimeRange(
                    event.schedule.startTime,
                    event.schedule.endTime,
                    event.schedule.duration,
                  ),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  event.classSchedule.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 2),
            // Row(
            //   children: [
            //     Icon(Icons.person, size: 16, color: Colors.grey[600]),
            //     const SizedBox(width: 4),
            //     Text(
            //       'GV: ${event.classSchedule.teacher.username}',
            //       style: TextStyle(color: Colors.grey[600]),
            //     ),
            //   ],
            // ),
          ],
        ),

        // trailing: FittedBox(
        //   fit: BoxFit.scaleDown,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //     decoration: BoxDecoration(
        //       color: subjectColor(event.classSchedule.subject).withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(12),
        //       border: Border.all(
        //         color: subjectColor(event.classSchedule.subject),
        //         width: 1,
        //       ),
        //     ),
        //     child: Text(
        //       event.schedule.dayOfWeek,
        //       style: TextStyle(
        //         color: subjectColor(event.classSchedule.subject),
        //         fontWeight: FontWeight.bold,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
