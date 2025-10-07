// bottom sheet chấm điểm
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class SubmissionDetailBottomSheet {
  static Future<bool> show({
    required BuildContext context,
    required Exercise exercise,
    required Submission submission,
    required String classId,
    required String exerciseId,
  }) async {
    final gradeController = TextEditingController(
      text: submission.grade != null ? submission.grade!.toString() : '',
    );
    final feedbackController = TextEditingController(text: submission.feedback ?? '');
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
              final maxScore = exercise.maxScore;
              if (parsed == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập điểm hợp lệ')),
                );
                return;
              }
              if (maxScore != null && (parsed < 0 || parsed > maxScore)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Điểm phải nằm trong khoảng 0 - $maxScore')),
                );
                return;
              }
              setSheetState(() => loading = true);
              try {
                final repo = ExerciseRepository();
                await repo.gradeSubmission(
                  classId: classId,
                  exerciseId: exerciseId,
                  submissionId: submission.id ?? '',
                  grade: parsed,
                  feedback: feedbackController.text.trim(),
                );
                graded = true;
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chấm điểm thành công')),
                  );
                }
              } catch (e) {
                setSheetState(() => loading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi chấm điểm: $e')),
                );
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
                      'Bài nộp của ${submission.student?.username ?? submission.studentId ?? 'Học sinh'}',
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
                          'Nộp lúc: ${submission.submittedAt != null ? _formatDate(submission.submittedAt!) : 'Không rõ'}',
                        ),
                        if (submission.isLate)
                          const Text(
                            'Nộp muộn',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nội dung văn bản
                    if ((submission.content ?? '').isNotEmpty) ...[
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
                          child: Text(submission.content ?? ''),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Tệp đính kèm
                    if ((submission.fileUrl ?? '').isNotEmpty) ...[
                      const Text(
                        'Tệp đính kèm',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file),
                        title: Text(_fileNameFromUrl(submission.fileUrl!)),
                        trailing: const Icon(Icons.download),
                        onTap: () {
                          final url = submission.fileUrl!;
                          final name = _fileNameFromUrl(url);
                          _downloadFile(context, url, name);
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Điểm',
                              hintText: exercise.maxScore != null ? '0 - ${exercise.maxScore}' : 'Nhập điểm',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        if (exercise.maxScore != null) ...[
                          const SizedBox(width: 8),
                          Text('/ ${exercise.maxScore}'),
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
                          onPressed: loading
                              ? null
                              : () {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã phê duyệt bài nộp')),
                                  );
                                },
                          child: const Text('Phê duyệt'),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: loading ? null : submitGrade,
                          icon: loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
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

  static String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  static String _fileNameFromUrl(String url) {
    try {
      final uri = Uri.tryParse(url);
      final last = uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : null;
      final clean = (last ?? '').split('?').first.split('#').first.trim();
      if (clean.isNotEmpty) return clean;
    } catch (_) {}
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'submission_$ts.bin';
  }

  static Future<void> _downloadFile(BuildContext context, String url, String fileName) async {
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
      final safeName = (fileName.isNotEmpty ? fileName : _fileNameFromUrl(fullUrl)).replaceAll('..', '.');
      final savePath = '${dir.path}/$safeName';
      final file = File(savePath);
      await file.writeAsBytes(data);

      messenger.showSnackBar(SnackBar(content: Text('Đã tải xuống: $safeName')));
      await OpenFilex.open(savePath);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lỗi tải tệp: $e')));
    }
  }
}