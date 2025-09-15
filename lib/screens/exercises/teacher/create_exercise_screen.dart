import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CreateExerciseScreen extends StatefulWidget {
  final String classId;
  const CreateExerciseScreen({super.key, required this.classId});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _maxScoreCtrl = TextEditingController();
  DateTime? _dueDate;
  String _type = 'essay';
  List<PlatformFile> _pickedFiles = const [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subjectCtrl.dispose();
    _maxScoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    if (time == null) return;
    if (!mounted) return;

    setState(() {
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hạn nộp (dueDate)')),
      );
      return;
    }

    final req = CreateExerciseRequest(
      title: _titleCtrl.text.trim(),
      // description is optional; omit if empty
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      type: _type,
      maxScore:
          _maxScoreCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_maxScoreCtrl.text.trim()),
      subject:
          _subjectCtrl.text.trim().isEmpty ? null : _subjectCtrl.text.trim(),
      dueDate: _dueDate!,
    );

    // Convert picked files to MultipartFiles
    Future<List<MultipartFile>> toMultipart(List<PlatformFile> files) async {
      final list = <MultipartFile>[];
      for (final f in files) {
        if (f.path == null) continue;
        final mimeType = lookupMimeType(f.path!) ?? 'application/octet-stream';
        list.add(
          await MultipartFile.fromFile(
            f.path!,
            filename: f.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
      return list;
    }

    // Dispatch with files (convert async then add)
    () async {
      final m = _pickedFiles.isEmpty ? null : await toMultipart(_pickedFiles);
      if (!mounted) return;
      context.read<ExerciseBloc>().add(
        CreateExerciseEvent(classId: widget.classId, request: req, files: m),
      );
    }();
  }

  Future<void> _pickFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (res == null) return;
    setState(() {
      _pickedFiles = res.files;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Tạo bài tập',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: BlocConsumer<ExerciseBloc, ExerciseState>(
        listener: (context, state) {
          if (state is ExerciseCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tạo bài tập thành công')),
            );
            Navigator.of(context).pop(state.response.data);
          }
          if (state is ExerciseError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final loading = state is ExerciseLoading;
          return AbsorbPointer(
            absorbing: loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------- Section 1: Thông tin chung -------
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Tiêu đề *',
                                prefixIcon: Icon(Icons.title),
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Vui lòng nhập tiêu đề'
                                          : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descCtrl,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Mô tả (tùy chọn)',
                                prefixIcon: Icon(Icons.notes),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _subjectCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Môn học (tùy chọn)',
                                prefixIcon: Icon(Icons.book),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _pickFiles,
                                    icon: const Icon(Icons.attach_file),
                                    label: const Text('Đính kèm tệp'),
                                  ),
                                  if (_pickedFiles.isNotEmpty)
                                    Text('${_pickedFiles.length} tệp đã chọn'),
                                ],
                              ),
                            ),
                            if (_pickedFiles.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _pickedFiles.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final f = _pickedFiles[index];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.insert_drive_file,
                                    ),
                                    title: Text(
                                      f.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${(f.size / 1024).toStringAsFixed(1)} KB',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _pickedFiles = List.of(_pickedFiles)
                                            ..removeAt(index);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ------- Section 2: Cấu hình -------
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _type,
                              decoration: const InputDecoration(
                                labelText: 'Loại bài tập',
                                prefixIcon: Icon(Icons.category),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'essay',
                                  child: Text('Tự luận'),
                                ),
                                DropdownMenuItem(
                                  value: 'multiple_choice',
                                  child: Text('Trắc nghiệm'),
                                ),
                                DropdownMenuItem(
                                  value: 'file_upload',
                                  child: Text('Nộp file'),
                                ),
                              ],
                              onChanged:
                                  (v) => setState(() => _type = v ?? 'essay'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _maxScoreCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Điểm tối đa (tùy chọn)',
                                prefixIcon: Icon(Icons.star),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _dueDate == null
                                        ? 'Chưa chọn hạn nộp'
                                        : 'Hạn nộp: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: _pickDueDate,
                                  icon: const Icon(Icons.date_range),
                                  label: const Text('Chọn hạn'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ------- Nút Submit -------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loading ? null : _submit,
                        icon:
                            loading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.save),
                        label: Text(loading ? 'Đang tạo...' : 'Tạo bài tập'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
