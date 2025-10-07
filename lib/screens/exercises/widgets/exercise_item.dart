import 'package:edusync/screens/exercises/exercise_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';

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

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'essay':
        return Colors.blue;
      case 'multiple_choice':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'essay':
        return Icons.edit_note;
      case 'multiple_choice':
        return Icons.quiz;
      default:
        return Icons.assignment;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'essay':
        return 'Tự luận';
      case 'multiple_choice':
        return 'Trắc nghiệm';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  bool _isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  Color _getPriorityColor() {
    final now = DateTime.now();
    final timeLeft = exercise.dueDate.difference(now).inHours;
    
    if (timeLeft < 0) return Colors.red; // Overdue
    if (timeLeft < 24) return Colors.orange; // Due soon
    if (timeLeft < 72) return Colors.amber; // Due in 3 days
    return Colors.green; // Good time left
  }

  String _getTimeLeftText() {
    final now = DateTime.now();
    final difference = exercise.dueDate.difference(now);
    
    if (difference.isNegative) {
      return 'Đã quá hạn';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    
    if (days > 0) {
      return 'Còn $days ngày';
    } else if (hours > 0) {
      return 'Còn $hours giờ';
    } else {
      return 'Còn $minutes phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(exercise.type);
    final isOverdue = _isOverdue(exercise.dueDate);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => ExerciseBloc(),
                  child: ExerciseDetailScreen(
                    classId: exercise.classId.id!,
                    exerciseId: exercise.id!,
                    role: isTeacher ? "teacher" : "student",
                    // exercise: exercise,
                  ),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with type and status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(exercise.type),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTypeLabel(exercise.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (submitted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Đã nộp',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Title
                Text(
                  exercise.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Class name
                if (exercise.classId.nameClass != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.class_, size: 14, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          exercise.classId.nameClass!,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Due date and time left
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: isOverdue ? Colors.red[600] : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hạn: ${_formatDate(exercise.dueDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverdue ? Colors.red[600] : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getPriorityColor()),
                      ),
                      child: Text(
                        _getTimeLeftText(),
                        style: TextStyle(
                          color: _getPriorityColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Teacher stats
                if (isTeacher) ...[
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Đã nộp: ${exercise.submissionCount ?? 0}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.assignment_turned_in, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Chưa chấm: ${exercise.ungradedCount ?? 0}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (_) => ExerciseBloc(),
                              child: ExerciseDetailScreen(
                                classId: exercise.classId.id!,
                                exerciseId: exercise.id!,
                                role: isTeacher ? "teacher" : "student",
                                // exercise: exercise,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        isTeacher
                            ? Icons.manage_accounts
                            : (submitted 
                                ? Icons.visibility 
                                : (isOverdue ? Icons.visibility : Icons.edit)),
                        size: 18,
                      ),
                      label: Text(
                        isTeacher
                            ? "Quản lý"
                            : (submitted 
                                ? "Xem kết quả" 
                                : (isOverdue ? "Xem chi tiết" : "Làm bài")),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTeacher
                            ? Colors.blue
                            : (submitted 
                                ? Colors.green 
                                : (isOverdue ? Colors.grey : Colors.orange)),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}