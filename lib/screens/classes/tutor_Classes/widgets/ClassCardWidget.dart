// Widget hiển thị thông tin từng lớp học dưới dạng thẻ (Card)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/screens/classes/tutor_Classes/class_detail_screen.dart';

class ClassCardWidget extends StatelessWidget {
  final ClassModel classItem;
  final String userRole;

  const ClassCardWidget({
    super.key,
    required this.classItem,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetailScreen(
                classId: classItem.id ?? '',
                className: classItem.nameClass,
                userRole: userRole,
              ),
            ),
          );
          if (result == true) {
            if (userRole.toLowerCase() == 'student') {
              context.read<ClassBloc>().add(GetRegisteredClassesEvent());
            } else {
              context.read<ClassBloc>().add(RefreshClassesEvent());
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.nameClass,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classItem.subject,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[600],
                          ),
                        ),
                        if (classItem.teacherName != null && classItem.teacherName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'GV: ${classItem.teacherName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (classItem.description != null && classItem.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  classItem.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  if (classItem.schedule.isNotEmpty) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getScheduleText(classItem.schedule),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (classItem.location != null && classItem.location!.isNotEmpty) ...[
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        classItem.location!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo: ${_formatDate(classItem.createdAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScheduleText(List<Schedule> schedule) {
    if (schedule.isEmpty) return '';
    if (schedule.length == 1) {
      final s = schedule.first;
      return '${s.dayOfWeek} ${s.startTime}-${s.endTime}';
    }
    return '${schedule.length} buổi/tuần';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ';
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}