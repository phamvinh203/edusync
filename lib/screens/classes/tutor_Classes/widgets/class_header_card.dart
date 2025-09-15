import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

class ClassHeaderCard extends StatelessWidget {
  final ClassModel classDetails;
  final ClassStudentsResponse? classStudents;
  final bool isTeacher;

  const ClassHeaderCard({
    super.key,
    required this.classDetails,
    this.classStudents,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            classDetails.nameClass,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (!isTeacher) ...[
            const SizedBox(height: 8),
            Text(
              'Giáo viên: '
              '${(classDetails.teacherName?.trim().isNotEmpty ?? false) ? classDetails.teacherName!.trim() : 'Không xác định'}',
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.people,
                text:
                    '${classStudents?.students.length ?? classDetails.students.length}/${classDetails.maxStudents ?? 0}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.schedule,
                text: '${classDetails.schedule.length} buổi/tuần',
              ),
              if (classDetails.location != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.location_on,
                  text: classDetails.location!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
