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
import 'package:edusync/screens/exercises/submit_exercise_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String classId;
  final String exerciseId;
  final String role; // 👈 Thêm role

  const ExerciseDetailScreen({
    super.key,
    required this.classId,
    required this.exerciseId,
    required this.role, // 👈 bắt buộc truyền
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _disposed = false; // Track disposal state
  ExerciseBloc? _exerciseBloc; // Store bloc reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save bloc reference safely during widget lifecycle
    _exerciseBloc ??= context.read<ExerciseBloc>();
  }

  @override
  void dispose() {
    _disposed = true; // Mark as disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !mounted || _exerciseBloc == null) return;
      _exerciseBloc!.add(
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
    // (trong trường hợp có vấn đề với ID format)
    for (var sub in exercise.submissions) {
      if (sub.studentId != null) {
        // Kiểm tra nếu ID tương tự (chỉ khác 1-2 ký tự cuối)
        final subId = sub.studentId!;
        final currentId = currentUserId;

        if (subId.length == currentId.length) {
          // So sánh từng phần của ID
          int diffCount = 0;
          for (int i = 0; i < subId.length; i++) {
            if (subId[i] != currentId[i]) {
              diffCount++;
            }
          }

          // Nếu chỉ khác nhau <= 2 ký tự, có thể là cùng user
          if (diffCount <= 2) {
            return sub;
          }
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
              // Kiểm tra disposed và mounted trước khi thực hiện actions
              if (_disposed || !mounted || _exerciseBloc == null) return;

              // Reload exercise detail when submit is successful
              if (state is ExerciseSubmitSuccess) {
                _exerciseBloc!.add(
                  LoadExerciseDetailEvent(
                    classId: widget.classId,
                    exerciseId: widget.exerciseId,
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

                      // Điểm tối đa
                      if (ex.maxScore != null)
                        Text(
                          "Điểm tối đa: ${ex.maxScore}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),

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
                              onTap: () {
                                _downloadFile(a.fileUrl, a.fileName);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 👇 Nếu role là teacher => hiển thị danh sách nộp
                      if (widget.role == 'teacher') ...[
                        const Text(
                          "Danh sách học sinh đã nộp",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "TODO: Hiển thị danh sách submissions ở đây",
                        ),
                      ],

                      // 👇 Nếu role là student => hiển thị nút nộp bài
                      if (widget.role == 'student') ...[
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: () {
                            final userSubmission = _getUserSubmission(
                              ex,
                              currentUserId,
                            );
                            final hasSubmitted = userSubmission != null;

                            if (hasSubmitted) {
                              return Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: null, // Disable button
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text("Đã nộp bài thành công"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.green,
                                      disabledForegroundColor: Colors.white,
                                    ),
                                  ),
                                  if (userSubmission.submittedAt != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Đã nộp lúc: ${_formatDate(userSubmission.submittedAt!)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            } else {
                              return ElevatedButton.icon(
                                onPressed: () async {
                                  if (_disposed ||
                                      !mounted ||
                                      _exerciseBloc == null)
                                    return;

                                  final result = await Navigator.of(
                                    context,
                                  ).push(
                                    MaterialPageRoute(
                                      builder:
                                          (_) => BlocProvider.value(
                                            value: _exerciseBloc!,
                                            child: SubmitExerciseScreen(
                                              classId: widget.classId,
                                              exerciseId: widget.exerciseId,
                                            ),
                                          ),
                                    ),
                                  );

                                  // Refresh exercise detail if submission was successful
                                  if (result == true &&
                                      !_disposed &&
                                      mounted &&
                                      _exerciseBloc != null) {
                                    _exerciseBloc!.add(
                                      LoadExerciseDetailEvent(
                                        classId: widget.classId,
                                        exerciseId: widget.exerciseId,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Nộp bài"),
                              );
                            }
                          }(),
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

  // Hàm tải file
  Future<void> _downloadFile(String url, String fileName) async {
    try {
      final dio = Dio();

      // Lấy thư mục tạm (có thể đổi thành thư mục Downloads)
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          // Download progress tracking could be added here if needed
        },
      );

      await OpenFilex.open(savePath);
    } catch (e) {
      // Download error handling
    }
  }
}
