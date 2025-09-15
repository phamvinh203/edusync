import 'package:edusync/screens/exercises/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final bool submitted;
  final bool isTeacher;

  const ExerciseItem({
    super.key,
    required this.exercise,
    required this.submitted,
    this.isTeacher = false,
  });

  @override
  Widget build(BuildContext context) {
    final dueDateStr =
        "${exercise.dueDate.day}/${exercise.dueDate.month}/${exercise.dueDate.year} ${exercise.dueDate.hour}:${exercise.dueDate.minute.toString().padLeft(2, '0')}";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        title: Text(
          exercise.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Hạn nộp: $dueDateStr",
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
            ),
            if (exercise.classId.nameClass != null)
              Text(
                "Lớp: ${exercise.classId.nameClass}",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            const SizedBox(height: 4),
            if (isTeacher) ...[
              Text(
                "Nộp bài: ${exercise.submissionCount ?? 0}",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                "Đã chấm: ${exercise.gradedCount ?? 0}/${exercise.submissionCount ?? 0}",
                style: TextStyle(
                  color:
                      (exercise.gradedCount ?? 0) ==
                                  (exercise.submissionCount ?? 0) &&
                              (exercise.submissionCount ?? 0) > 0
                          ? Colors.green
                          : Colors.orange,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (exercise.averageGrade != null)
                Text(
                  "Điểm TB: ${exercise.averageGrade!.toStringAsFixed(1)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
            ] else ...[
              Text(
                submitted ? "✅ Đã nộp" : "⌛ Chưa nộp",
                style: TextStyle(
                  color: submitted ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ExerciseDetailScreen(
                      classId: exercise.classId.id!, // từ model Exercise
                      exerciseId: exercise.id!, // id của bài tập
                      role:
                          isTeacher
                              ? "teacher"
                              : "student", // role based on isTeacher
                      exercise: exercise, // truyền luôn object exercise
                    ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isTeacher
                    ? Colors.blue
                    : (submitted ? Colors.blue : Colors.green),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isTeacher ? "Quản lý" : (submitted ? "Xem" : "Làm")),
        ),
      ),
    );
  }
}
