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
    final feedbackController = TextEditingController(
      text: submission.feedback ?? '',
    );
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
                  const SnackBar(
                    content: Text('Vui lòng nhập điểm hợp lệ'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (maxScore != null && (parsed < 0 || parsed > maxScore)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Điểm phải nằm trong khoảng 0 - $maxScore'),
                    backgroundColor: Colors.orange,
                  ),
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
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Đã chấm điểm: ${parsed.toStringAsFixed(1)}${maxScore != null ? '/$maxScore' : ''} điểm',
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                setSheetState(() => loading = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Lỗi chấm điểm: $e')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
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
                    // Header với tên học sinh
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(Icons.person, color: Colors.blue[700]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  submission.student?.username ??
                                      submission.studentId ??
                                      'Học sinh',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Nộp lúc: ${submission.submittedAt != null ? _formatDate(submission.submittedAt!) : 'Không rõ'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (submission.isLate)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Nộp muộn',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

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

                    // Hiển thị điểm hiện tại nếu đã chấm
                    if (submission.grade != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.grade, color: Colors.green[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Điểm hiện tại: ${submission.grade!.toStringAsFixed(1)}${exercise.maxScore != null ? ' / ${exercise.maxScore}' : ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

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
                                  exercise.maxScore != null
                                      ? '0 - ${exercise.maxScore}'
                                      : 'Nhập điểm',
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
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : submitGrade,
                            icon:
                                loading
                                    ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Icon(Icons.check_circle),
                            label: Text(loading ? 'Đang lưu...' : 'Chấm điểm'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
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
      final last =
          uri?.pathSegments.isNotEmpty == true ? uri!.pathSegments.last : null;
      final clean = (last ?? '').split('?').first.split('#').first.trim();
      if (clean.isNotEmpty) return clean;
    } catch (_) {}
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'submission_$ts.bin';
  }

  static Future<void> _downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
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
}
