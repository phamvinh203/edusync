import 'dart:io';

import 'package:edusync/screens/exercises/student/essay_exercise_section.dart';
import 'package:edusync/screens/exercises/student/mcq_exercise_section.dart';
import 'package:edusync/screens/exercises/teacher/teacher_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String classId;
  final String exerciseId;
  final String role;

  const ExerciseDetailScreen({
    super.key,
    required this.classId,
    required this.exerciseId,
    required this.role,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late ExerciseBloc _exerciseBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _exerciseBloc = context.read<ExerciseBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _exerciseBloc.add(
        LoadExerciseDetailEvent(
          classId: widget.classId,
          exerciseId: widget.exerciseId,
        ),
      );
    });
  }

  Submission? _getUserSubmission(Exercise exercise, String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return null;
    // Tìm exact match trước
    for (var sub in exercise.submissions) {
      if (sub.studentId == currentUserId) {
        return sub;
      }
    }

    // Nếu không tìm thấy exact match, thử tìm partial match
    for (var sub in exercise.submissions) {
      if (sub.studentId != null) {
        final subId = sub.studentId!;
        final currentId = currentUserId;
        if (subId.length == currentId.length) {
          int diffCount = 0;
          for (int i = 0; i < subId.length; i++) {
            if (subId[i] != currentId[i]) diffCount++;
          }
          if (diffCount <= 2) return sub;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài tập')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExerciseBloc, ExerciseState>(
            listener: (context, state) {
              if (!mounted) return;

              // Reload khi nộp bài thành công
              if (state is ExerciseSubmitSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.response.message.isNotEmpty
                          ? state.response.message
                          : 'Nộp bài thành công',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                _exerciseBloc.add(
                  LoadExerciseDetailEvent(
                    classId: widget.classId,
                    exerciseId: widget.exerciseId,
                  ),
                );
              }

              // Hiển thị lỗi nếu có
              if (state is ExerciseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ExerciseBloc, ExerciseState>(
          builder: (context, state) {
            if (state is ExerciseDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ExerciseError) {
              return Center(child: Text(state.message));
            }
            if (state is! ExerciseDetailLoaded) {
              return const SizedBox.shrink();
            }
            final Exercise ex = state.exercise;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final currentUserId = authState.user?.id;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        ex.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Chips thông tin
                      Wrap(
                        spacing: 8,
                        runSpacing: -6,
                        children: [
                          _chip(_typeLabel(ex.type), _typeColor(ex.type)),
                          _chip(
                            _statusLabel(ex.status),
                            _statusColor(ex.status),
                          ),
                          if ((ex.subject ?? '').isNotEmpty)
                            _chip('Môn: ${ex.subject}', Colors.teal),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Thời gian
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tạo lúc: ${_formatDate(ex.createdAt ?? ex.startDate ?? DateTime.now())}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Hạn: ${_formatDate(ex.dueDate)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Điểm
                      if (widget.role == 'student') ...[
                        Builder(
                          builder: (_) {
                            final userSubmission = _getUserSubmission(
                              ex,
                              currentUserId,
                            );
                            if (userSubmission?.grade != null) {
                              final g = userSubmission!.grade!;
                              final max = ex.maxScore ?? 10;
                              final text =
                                  'Điểm của bạn: ${g.toStringAsFixed(1)}/$max';
                              return Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              );
                            } else if (userSubmission != null) {
                              return const Text(
                                'Bài nộp của bạn: Chưa chấm',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ] else if (ex.maxScore != null) ...[
                        Text(
                          'Điểm tối đa: ${ex.maxScore}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Mô tả
                      if ((ex.description ?? '').isNotEmpty) ...[
                        const Text(
                          'Mô tả',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(ex.description!),
                        const SizedBox(height: 16),
                      ],

                      // Tệp đính kèm
                      if (ex.attachments.isNotEmpty) ...[
                        const Text(
                          'Tệp đính kèm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ex.attachments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final a = ex.attachments[index];
                            return ListTile(
                              leading: const Icon(Icons.insert_drive_file),
                              title: Text(a.fileName),
                              subtitle: Text(
                                '${a.mimeType ?? ''} · ${(a.fileSize ?? 0) ~/ 1024} KB',
                              ),
                              trailing: const Icon(Icons.download),
                              onTap: () => _downloadFile(a.fileUrl, a.fileName),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Phần giáo viên
                      if (widget.role == 'teacher') ...[
                        TeacherSection(
                          classId: widget.classId,
                          exerciseId: widget.exerciseId,
                          exercise: ex,
                        ),
                      ],

                      // Phần học sinh
                      // Phần học sinh
                      if (widget.role == 'student') ...[
                        const SizedBox(height: 20),
                        Builder(
                          builder: (ctx) {
                            final userSubmission = _getUserSubmission(
                              ex,
                              currentUserId,
                            );
                            final hasSubmitted = userSubmission != null;
                            final now = DateTime.now();
                            final stillInDeadline = ex.dueDate.isAfter(now);
                            final graded =
                                userSubmission?.grade !=
                                null; // Đã chấm điểm hay chưa

                            // Nếu chưa nộp
                            if (!hasSubmitted &&
                                ex.type == 'multiple_choice' &&
                                ex.questions.isNotEmpty) {
                              return McqExerciseSection(
                                exercise: ex,
                                classId: widget.classId,
                                exerciseId: widget.exerciseId,
                                onSubmitted: () {
                                  if (mounted) {
                                    _exerciseBloc.add(
                                      LoadExerciseDetailEvent(
                                        classId: widget.classId,
                                        exerciseId: widget.exerciseId,
                                      ),
                                    );
                                  }
                                },
                              );
                            } else if (!hasSubmitted && ex.type == 'essay') {
                              return EssayExerciseSection(
                                classId: widget.classId,
                                exerciseId: widget.exerciseId,
                                onSubmitted: () {
                                  if (mounted) {
                                    _exerciseBloc.add(
                                      LoadExerciseDetailEvent(
                                        classId: widget.classId,
                                        exerciseId: widget.exerciseId,
                                      ),
                                    );
                                  }
                                },
                              );
                            }

                            // Nếu đã nộp
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.15,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Bạn đã nộp bài thành công',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (userSubmission?.submittedAt !=
                                        null) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        '⏰ Đã nộp lúc: ${_formatDate(userSubmission!.submittedAt!)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],

                                    // Hiển thị điểm nếu đã chấm
                                    if (graded) ...[
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.grade,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '🏆 Điểm: ${userSubmission!.grade!.toStringAsFixed(1)} / ${ex.maxScore ?? 10}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    // Nếu chưa chấm và còn hạn thì cho phép làm lại
                                    if (!graded && stillInDeadline) ...[
                                      const Divider(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Làm lại bài tập'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade600,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          onPressed: () {
                                            _showRedoConfirmationDialog(
                                              context,
                                              userSubmission,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'file_upload':
        return 'Nộp file';
      case 'essay':
      default:
        return 'Tự luận';
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.purple;
      case 'file_upload':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'closed') return 'Đã đóng';
    if (s == 'graded') return 'Đã chấm';
    return 'Đang mở';
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'closed') return Colors.grey;
    if (s == 'graded') return Colors.blueGrey;
    return Colors.green;
  }

  Widget _chip(String text, Color color) {
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.3)),
      labelStyle: TextStyle(color: color),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _downloadFile(String url, String fileName) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      String fullUrl = url;
      final client = Dio();
      final Response resp = await client.get(
        fullUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );

      if (resp.statusCode != null && resp.statusCode! >= 400) {
        throw Exception('Mã lỗi ${resp.statusCode}');
      }

      final data = resp.data;
      if (data is! List<int>) {
        throw Exception('Phản hồi không phải dữ liệu tệp');
      }

      final dir = await getApplicationDocumentsDirectory();
      final safeName = (fileName.isNotEmpty
              ? fileName
              : _fileNameFromUrl(fullUrl))
          .replaceAll('..', '.');
      final savePath = '${dir.path}/$safeName';
      final file = File(savePath);
      await file.writeAsBytes(data);

      messenger.showSnackBar(
        SnackBar(content: Text('Đã tải xuống: $safeName')),
      );
      await OpenFilex.open(savePath);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi tải tệp: $e')));
    }
  }

  String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      final last =
          uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : null;
      final clean = (last ?? '').split('?').first.split('#').first.trim();
      if (clean.isNotEmpty) return clean;
    } catch (_) {}
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'submission_$ts.bin';
  }

  void _showRedoConfirmationDialog(
    BuildContext context,
    Submission? userSubmission,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Làm lại bài tập'),
              ],
            ),
            content: const Text(
              'Bạn có chắc chắn muốn làm lại?\n\nBài nộp trước đó sẽ bị xóa hoàn toàn.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Xác nhận'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);

                  if (userSubmission?.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không tìm thấy bài nộp để xóa'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Gửi event xóa submission cũ
                  _exerciseBloc.add(
                    RedoSubmissionEvent(
                      classId: widget.classId,
                      exerciseId: widget.exerciseId,
                      submissionId: userSubmission!.id,
                    ),
                  );

                  // Hiển thị thông báo đang xử lý
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Đang xóa bài nộp cũ...'),
                        ],
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}
