// phần danh sách + chấm điểm của giáo viên
import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'submission_detail_bottomsheet.dart';

class TeacherSection extends StatelessWidget {
  final String classId;
  final String exerciseId;
  final Exercise exercise;

  const TeacherSection({
    super.key,
    required this.classId,
    required this.exerciseId,
    required this.exercise,
  });

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Danh sách học sinh đã nộp",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        FutureBuilder<List<Submission>>(
          future: ExerciseRepository().getSubmissions(
            classId: classId,
            exerciseId: exerciseId,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(minHeight: 2),
              );
            }
            if (snap.hasError) {
              return Text(
                'Lỗi tải danh sách: ${snap.error}',
                style: const TextStyle(color: Colors.red),
              );
            }
            final list = snap.data ?? const [];
            if (list.isEmpty) {
              return const Text(
                'Chưa có học sinh nào nộp',
                style: TextStyle(color: Colors.grey),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sub = list[index];
                final studentName = (sub.student?.username ?? '').isNotEmpty
                    ? sub.student!.username!
                    : (sub.studentId ?? 'Không rõ');
                final submittedAt = sub.submittedAt != null
                    ? _formatDate(sub.submittedAt!)
                    : 'Không rõ thời gian';
                final gradeText = sub.grade != null
                    ? 'Điểm: ${sub.grade!.toStringAsFixed(1)}${exercise.maxScore != null ? '/${exercise.maxScore}' : ''}'
                    : (sub.feedback != null ? 'Đã nhận xét' : 'Chưa chấm');
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    studentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nộp lúc: $submittedAt'),
                      const SizedBox(height: 2),
                      Text(
                        gradeText,
                        style: TextStyle(
                          color: sub.grade != null ? Colors.green[700] : Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final graded = await SubmissionDetailBottomSheet.show(
                      context: context,
                      exercise: exercise,
                      submission: sub,
                      classId: classId,
                      exerciseId: exerciseId,
                    );
                    if (graded == true) {
                      // Trigger rebuild by calling setState in parent if needed
                    }
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}