import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';

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
    required this.role, required Exercise exercise,
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
              if (_disposed || !mounted || _exerciseBloc == null) return;
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
                              final max = ex.maxScore;
                              final text =
                                  max != null
                                      ? 'Điểm của bạn: ${g.toStringAsFixed(1)}/$max'
                                      : 'Điểm của bạn: ${g.toStringAsFixed(1)}';
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
                        FutureBuilder<List<Submission>>(
                          future: () async {
                            // Gọi API submissions trực tiếp từ repository
                            return ExerciseRepository().getSubmissions(
                              classId: widget.classId,
                              exerciseId: widget.exerciseId,
                            );
                          }(),
                          builder: (context, snap) {
                            if (snap.connectionState ==
                                ConnectionState.waiting) {
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
                              separatorBuilder:
                                  (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final sub = list[index];
                                final studentName =
                                    (sub.student?.username ?? '').isNotEmpty
                                        ? sub.student!.username!
                                        : (sub.studentId ?? 'Không rõ');
                                final submittedAt =
                                    sub.submittedAt != null
                                        ? _formatDate(sub.submittedAt!)
                                        : 'Không rõ thời gian';
                                final gradeText =
                                    sub.grade != null
                                        ? 'Điểm: ${sub.grade!.toStringAsFixed(1)}${ex.maxScore != null ? '/${ex.maxScore}' : ''}'
                                        : (sub.feedback != null
                                            ? 'Đã nhận xét'
                                            : 'Chưa chấm');
                                // Nội dung chi tiết và file sẽ xem ở màn chi tiết

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(
                                    studentName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Nộp lúc: $submittedAt'),
                                      const SizedBox(height: 2),
                                      Text(
                                        gradeText,
                                        style: TextStyle(
                                          color:
                                              sub.grade != null
                                                  ? Colors.green[700]
                                                  : Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () async {
                                    final graded = await _openSubmissionDetail(
                                      context,
                                      ex,
                                      sub,
                                    );
                                    if (graded == true) {
                                      if (mounted) setState(() {});
                                    }
                                  },
                                );
                              },
                            );
                          },
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

  // Suy luận tên file từ URL nếu không có sẵn
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

  // BottomSheet: Chi tiết bài làm + chấm điểm
  Future<bool> _openSubmissionDetail(
    BuildContext context,
    Exercise ex,
    Submission sub,
  ) async {
    final gradeController = TextEditingController(
      text: sub.grade != null ? sub.grade!.toString() : '',
    );
    final feedbackController = TextEditingController(text: sub.feedback ?? '');

    bool graded = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            bool loading = false;

            Future<void> submitGrade() async {
              final text = gradeController.text.trim();
              final parsed = double.tryParse(text);
              final maxScore = ex.maxScore;
              if (parsed == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ')),
                );
                return;
              }
              if (maxScore != null && (parsed < 0 || parsed > maxScore)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Điểm phải nằm trong khoảng 0 - $maxScore'),
                  ),
                );
                return;
              }
              setSheetState(() => loading = true);
              try {
                final repo = ExerciseRepository();
                await repo.gradeSubmission(
                  classId: widget.classId,
                  exerciseId: widget.exerciseId,
                  submissionId: sub.id ?? '',
                  grade: parsed,
                  feedback: feedbackController.text.trim(),
                );
                graded = true;
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chấm điểm thành công')),
                  );
                }
              } catch (e) {
                setSheetState(() => loading = false);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi chấm điểm: $e')));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                top: 8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bài nộp của ${sub.student?.username ?? sub.studentId ?? 'Học sinh'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nộp lúc: ${sub.submittedAt != null ? _formatDate(sub.submittedAt!) : 'Không rõ'}',
                        ),
                        if (sub.isLate)
                          const Text(
                            'Nộp muộn',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nội dung văn bản
                    if ((sub.content ?? '').isNotEmpty) ...[
                      const Text(
                        'Nội dung bài làm',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 240),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Text(sub.content ?? ''),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Tệp đính kèm
                    if ((sub.fileUrl ?? '').isNotEmpty) ...[
                      const Text(
                        'Tệp đính kèm',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(_fileNameFromUrl(sub.fileUrl!)),
                        trailing: const Icon(Icons.download),
                        onTap: () {
                          final url = sub.fileUrl!;
                          final name = _fileNameFromUrl(url);
                          _downloadFile(url, name);
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Divider(height: 24),

                    // Nhập điểm
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: gradeController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Điểm',
                              hintText:
                                  ex.maxScore != null
                                      ? '0 - ${ex.maxScore}'
                                      : 'Nhập điểm',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        if (ex.maxScore != null) ...[
                          const SizedBox(width: 8),
                          Text('/ ${ex.maxScore}'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nhận xét
                    TextField(
                      controller: feedbackController,
                      decoration: const InputDecoration(
                        labelText: 'Nhận xét',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 2,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        TextButton(
                          onPressed:
                              loading
                                  ? null
                                  : () {
                                    // Phê duyệt: tạm thời chỉ đóng BottomSheet
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã phê duyệt bài nộp'),
                                      ),
                                    );
                                  },
                          child: const Text('Phê duyệt'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: loading ? null : submitGrade,
                          icon:
                              loading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.check),
                          label: const Text('Chấm điểm'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    return graded;
  }
}
