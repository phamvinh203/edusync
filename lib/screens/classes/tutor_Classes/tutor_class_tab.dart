import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/screens/classes/tutor_Classes/class_detail_screen.dart';

class TutorClassTab extends StatefulWidget {
  const TutorClassTab({super.key});

  @override
  State<TutorClassTab> createState() => _TutorClassTabState();
}

class _TutorClassTabState extends State<TutorClassTab> {
  @override
  void initState() {
    super.initState();
    // Load danh sách lớp học khi khởi tạo
    context.read<ClassBloc>().add(LoadClassesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClassError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ClassBloc>().add(LoadClassesEvent());
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        // Lấy danh sách lớp học từ state
        List<ClassModel> classes = [];
        if (state is ClassLoaded) {
          classes = state.classes;
        } else if (state is ClassCreateSuccess) {
          classes = state.allClasses;
        }

        if (classes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có lớp gia sư nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo lớp gia sư đầu tiên của bạn',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ClassBloc>().add(RefreshClassesEvent());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classItem = classes[index];
              return _buildClassCard(classItem);
            },
          ),
        );
      },
    );
  }

  Widget _buildClassCard(ClassModel classItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Điều hướng đến màn hình chi tiết lớp học
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ClassDetailScreen(
                    classId: classItem.id ?? '',
                    className: classItem.nameClass,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên lớp và môn học
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
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${classItem.students.length}/${classItem.maxStudents ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Mô tả (nếu có)
              if (classItem.description != null &&
                  classItem.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  classItem.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Thông tin thêm
              const SizedBox(height: 12),
              Row(
                children: [
                  // Lịch học
                  if (classItem.schedule.isNotEmpty) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getScheduleText(classItem.schedule),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Địa điểm (nếu có)
                  if (classItem.location != null &&
                      classItem.location!.isNotEmpty) ...[
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

              // Thời gian tạo
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
