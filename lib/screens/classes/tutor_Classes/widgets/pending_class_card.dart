import 'package:edusync/models/class_model.dart';
import 'package:flutter/material.dart';

class PendingClassCard extends StatelessWidget {
  final ClassModel classItem;

  const PendingClassCard({super.key, required this.classItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pending_actions,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.nameClass,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Môn học: ${classItem.subject}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      'Lớp: ${classItem.gradeLevel ?? "N/A"}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    if (classItem.teacherName != null &&
                        classItem.teacherName!.isNotEmpty)
                      Text(
                        'Giáo viên: ${classItem.teacherName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (classItem.schedule.isNotEmpty)
                      Text(
                        'Lịch: ${_getScheduleText(classItem.schedule)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (classItem.location != null &&
                        classItem.location!.isNotEmpty)
                      Text(
                        'Địa chỉ: ${classItem.location}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Trạng thái
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 18,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Đang chờ giáo viên duyệt',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  String _getScheduleText(List<Schedule> schedule) {
    if (schedule.isEmpty) return '';

    if (schedule.length == 1) {
      final s = schedule.first;
      return '${s.dayOfWeek} ${s.startTime}-${s.endTime}';
    }

    return '${schedule.length} buổi/tuần';
  }
}
