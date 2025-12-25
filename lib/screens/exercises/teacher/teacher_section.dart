// phần danh sách + chấm điểm của giáo viên
import 'package:flutter/material.dart';
import 'package:edusync/l10n/app_localizations.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'submission_detail_bottomsheet.dart';

class TeacherSection extends StatefulWidget {
  final String classId;
  final String exerciseId;
  final Exercise exercise;

  const TeacherSection({
    super.key,
    required this.classId,
    required this.exerciseId,
    required this.exercise,
  });

  @override
  State<TeacherSection> createState() => _TeacherSectionState();
}

class _TeacherSectionState extends State<TeacherSection> {
  // Key để force rebuild FutureBuilder
  int _refreshKey = 0;

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  void _reloadSubmissions() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.submittedStudentsTitle,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _reloadSubmissions,
              tooltip: AppLocalizations.of(context)!.reload,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FutureBuilder<List<Submission>>(
          key: ValueKey(_refreshKey), // Force rebuild khi key thay đổi
          future: ExerciseRepository().getSubmissions(
            classId: widget.classId,
            exerciseId: widget.exerciseId,
          ),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(minHeight: 2),
              );
            }
            if (snap.hasError) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${AppLocalizations.of(context)!.errorLoadingList}: ${snap.error}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              );
            }
            final list = snap.data ?? const [];
            if (list.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.noSubmissionsYet,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }
            return Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sub = list[index];
                  final studentName =
                      (sub.student?.username ?? '').isNotEmpty
                          ? sub.student!.username!
                          : (sub.studentId ??
                              AppLocalizations.of(context)!.unknownStudent);
                  final submittedAt =
                      sub.submittedAt != null
                          ? _formatDate(sub.submittedAt!)
                          : AppLocalizations.of(context)!.unknownTime;
                  final gradeText =
                      sub.grade != null
                          ? '${AppLocalizations.of(context)!.scorePrefix}: ${sub.grade!.toStringAsFixed(1)}${widget.exercise.maxScore != null ? '/${widget.exercise.maxScore}' : ''}'
                          : (sub.feedback != null
                              ? AppLocalizations.of(context)!.hasFeedback
                              : AppLocalizations.of(context)!.notGraded);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          sub.grade != null
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                      child: Icon(
                        Icons.person,
                        color:
                            sub.grade != null
                                ? Colors.green[700]
                                : Colors.orange[700],
                      ),
                    ),
                    title: Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              submittedAt,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          gradeText,
                          style: TextStyle(
                            color:
                                sub.grade != null
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final graded = await SubmissionDetailBottomSheet.show(
                        context: context,
                        exercise: widget.exercise,
                        submission: sub,
                        classId: widget.classId,
                        exerciseId: widget.exerciseId,
                      );
                      // Reload danh sách nếu đã chấm điểm
                      if (graded == true) {
                        _reloadSubmissions();
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
