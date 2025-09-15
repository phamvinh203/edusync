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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ClassDetailScreen(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Tên lớp + nhãn "Gia sư"
              Row(
                children: [
                  Text(
                    classItem.nameClass,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Gia sư',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Giáo viên
              if (classItem.teacherName != null &&
                  classItem.teacherName!.isNotEmpty)
                Text(
                  'Giáo viên: ${classItem.teacherName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),

              const SizedBox(height: 4),

              // Lịch học
              if (classItem.schedule.isNotEmpty)
                Text(
                  'Lịch: ${_getScheduleText(classItem.schedule)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),

              const SizedBox(height: 4),

              // Địa chỉ
              if (classItem.location != null && classItem.location!.isNotEmpty)
                Text(
                  'Địa chỉ: ${classItem.location}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: mở màn hình bài tập
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.assignment_turned_in, size: 18),
                      label: const Text('Bài tập'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ClassDetailScreen(
                                  classId: classItem.id ?? '',
                                  className: classItem.nameClass,
                                  userRole: userRole,
                                ),
                          ),
                        );
                        if (result == true) {
                          if (userRole.toLowerCase() == 'student') {
                            context.read<ClassBloc>().add(
                              GetRegisteredClassesEvent(),
                            );
                          } else {
                            context.read<ClassBloc>().add(
                              RefreshClassesEvent(),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Chi tiết'),
                    ),
                  ),
                ],
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
}
