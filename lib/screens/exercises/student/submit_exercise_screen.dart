import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http_parser/http_parser.dart';

import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';

class SubmitExerciseScreen extends StatefulWidget {
  final String classId;
  final String exerciseId;

  const SubmitExerciseScreen({
    super.key,
    required this.classId,
    required this.exerciseId,
  });

  @override
  State<SubmitExerciseScreen> createState() => _SubmitExerciseScreenState();
}

class _SubmitExerciseScreenState extends State<SubmitExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentCtrl = TextEditingController();
  PlatformFile? _pickedFile;
  bool _submitting = false;
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
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withReadStream: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<MultipartFile?> _toMultipart(PlatformFile? f) async {
    if (f == null) return null;
    if (f.path != null) {
      return MultipartFile.fromFile(
        f.path!,
        filename: f.name,
        contentType: _inferContentType(f.name),
      );
    }
    if (f.readStream != null) {
      // Fallback: provide a function that returns the stream (dio v5 signature)
      return MultipartFile.fromStream(
        () => f.readStream!,
        f.size,
        filename: f.name,
        contentType: _inferContentType(f.name),
      );
    }
    return null;
  }

  MediaType? _inferContentType(String name) {
    // Lightweight detection using extension only
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'ppt':
        return MediaType('application', 'vnd.ms-powerpoint');
      case 'pptx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.presentationml.presentation',
        );
      default:
        return null; // let Dio guess
    }
  }

  void _submit() async {
    // Kiểm tra disposed và mounted trước khi bắt đầu
    if (_disposed || !mounted) return;

    if ((_contentCtrl.text.trim().isEmpty) && _pickedFile == null) {
      if (_disposed || !mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung hoặc chọn tệp.')),
      );
      return;
    }

    if (_disposed || !mounted) return;
    setState(() => _submitting = true);

    try {
      final mp = await _toMultipart(_pickedFile);

      // Kiểm tra disposed và mounted sau async operation
      if (_disposed || !mounted || _exerciseBloc == null) return;

      _exerciseBloc!.add(
        SubmitExerciseRequested(
          classId: widget.classId,
          exerciseId: widget.exerciseId,
          content:
              _contentCtrl.text.trim().isEmpty
                  ? null
                  : _contentCtrl.text.trim(),
          file: mp,
        ),
      );
    } finally {
      // We'll stop loading when we receive state change
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        // Kiểm tra disposed và mounted trước khi cập nhật state
        if (_disposed || !mounted) return;

        if (state is ExerciseSubmitting) {
          setState(() => _submitting = true);
        } else {
          setState(() => _submitting = false);
        }

        if (state is ExerciseSubmitSuccess) {
          // Kiểm tra disposed và mounted trước khi show snackbar và navigate
          if (_disposed || !mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.response.message.isNotEmpty
                    ? state.response.message
                    : 'Nộp bài thành công',
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
        if (state is ExerciseError) {
          // Kiểm tra disposed và mounted trước khi show snackbar
          if (_disposed || !mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nộp bài')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập nội dung',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentCtrl,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText:
                          'Viết câu trả lời... (có thể để trống nếu nộp tệp) ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _submitting ? null : _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Chọn tệp'),
                      ),
                      const SizedBox(width: 12),
                      if (_pickedFile != null)
                        Expanded(
                          child: Text(
                            '${_pickedFile!.name} • ${((_pickedFile!.size) / 1024).toStringAsFixed(1)} KB',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _submit,
                      icon:
                          _submitting
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.send),
                      label: Text(_submitting ? 'Đang nộp...' : 'Nộp bài'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
