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

class _CreateExerciseScreenState extends State<CreateExerciseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _maxScoreController = TextEditingController();
  
  late TabController _tabController;
  DateTime? _dueDate;
  String _selectedType = 'essay';
  List<PlatformFile> _attachments = [];
  
  // Trắc nghiệm
  final List<Question> _mcQuestions = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedType = _tabController.index == 0 ? 'essay' : 'multiple_choice';
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _maxScoreController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    
    if (date == null) return;
    if (!mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 23, minute: 59),
    );
    
    if (time == null) return;
    if (!mounted) return;
    
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    
    if (result != null) {
      setState(() {
        _attachments = result.files;
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _addMCQuestion() {
    showDialog(
      context: context,
      builder: (context) => _MCQuestionDialog(
        onAdd: (question) {
          setState(() {
            _mcQuestions.add(question);
          });
        },
      ),
    );
  }

  void _editMCQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => _MCQuestionDialog(
        question: _mcQuestions[index],
        onAdd: (question) {
          setState(() {
            _mcQuestions[index] = question;
          });
        },
      ),
    );
  }

  void _removeMCQuestion(int index) {
    setState(() {
      _mcQuestions.removeAt(index);
    });
  }

  Future<List<MultipartFile>?> _convertToMultipartFiles() async {
    if (_attachments.isEmpty) return null;
    
    final List<MultipartFile> multipartFiles = [];
    for (final file in _attachments) {
      if (file.path != null) {
        final mimeType = lookupMimeType(file.path!) ?? 'application/octet-stream';
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }
    }
    return multipartFiles.isEmpty ? null : multipartFiles;
  }

  void _submitExercise() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hạn nộp bài')),
      );
      return;
    }
    
    if (_selectedType == 'multiple_choice' && _mcQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một câu hỏi trắc nghiệm')),
      );
      return;
    }

    final request = CreateExerciseRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: _selectedType,
      questions: _selectedType == 'multiple_choice' ? _mcQuestions : [],
      attachments: [], // Sẽ được xử lý bởi server từ files
      maxScore: _maxScoreController.text.trim().isEmpty 
          ? null 
          : int.tryParse(_maxScoreController.text.trim()),
      subject: _subjectController.text.trim().isEmpty 
          ? null 
          : _subjectController.text.trim(),
      dueDate: _dueDate!,
    );

    final files = await _convertToMultipartFiles();
    
    if (!mounted) return;
    context.read<ExerciseBloc>().add(
      CreateExerciseEvent(
        classId: widget.classId,
        request: request,
        files: files,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Tạo bài tập mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ExerciseBloc, ExerciseState>(
        listener: (context, state) {
          if (state is ExerciseCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tạo bài tập thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(state.response.data);
          } else if (state is ExerciseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ExerciseLoading;
          
          return Form(
            key: _formKey,
            child: Column(
              children: [
                // Tab selector
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.blue,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.edit_note),
                        text: 'Tự luận',
                      ),
                      Tab(
                        icon: Icon(Icons.quiz),
                        text: 'Trắc nghiệm',
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEssayTab(),
                      _buildMultipleChoiceTab(),
                    ],
                  ),
                ),
                
                // Submit button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Tạo bài tập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEssayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildAttachmentsCard(),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildQuestionsCard(),
          // const SizedBox(height: 16),
          // _buildAttachmentsCard(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Thông tin cơ bản',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề bài tập',
                hintText: 'Nhập tiêu đề cho bài tập...',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'Mô tả chi tiết về bài tập...',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Môn học (tùy chọn)',
                hintText: 'Toán, Văn, Anh...',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Cài đặt bài tập',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxScoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Điểm tối đa (tùy chọn)',
                      hintText: '10',
                      prefixIcon: const Icon(Icons.grade),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final score = int.tryParse(value.trim());
                        if (score == null || score <= 0) {
                          return 'Điểm phải là số nguyên dương';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectDueDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[50],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'Chọn hạn nộp'
                                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year} ${_dueDate!.hour}:${_dueDate!.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: _dueDate == null 
                                    ? Colors.grey[600] 
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _buildQuestionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Câu hỏi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _addMCQuestion,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm câu hỏi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_mcQuestions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.quiz, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có câu hỏi nào',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nhấn "Thêm câu hỏi" để bắt đầu',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _mcQuestions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final question = _mcQuestions[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editMCQuestion(index),
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.blue[700],
                            ),
                            IconButton(
                              onPressed: () => _removeMCQuestion(index),
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red[700],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...question.options.asMap().entries.map((entry) {
                          final optionIndex = entry.key;
                          final option = entry.value;
                          final isCorrect = question.correctAnswers.contains(optionIndex);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${String.fromCharCode(65 + optionIndex)}. $option',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                                    color: isCorrect ? Colors.green[800] : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: Colors.purple[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Tệp đính kèm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: _pickAttachments,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Đính kèm tệp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple[600],
                    side: BorderSide(color: Colors.purple[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_attachments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.attach_file, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có tệp đính kèm',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đính kèm tài liệu, hình ảnh... (tùy chọn)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attachments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final file = _attachments[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: Colors.purple[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${(file.size / 1024).toStringAsFixed(1)} KB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeAttachment(index),
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _MCQuestionDialog extends StatefulWidget {
  final Question? question;
  final Function(Question) onAdd;

  const _MCQuestionDialog({
    this.question,
    required this.onAdd,
  });

  @override
  State<_MCQuestionDialog> createState() => _MCQuestionDialogState();
}

class _MCQuestionDialogState extends State<_MCQuestionDialog> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late Set<int> _correctAnswers;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question?.question ?? '');
    _optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: (widget.question?.options.length ?? 0) > index 
            ? widget.question!.options[index] 
            : '',
      ),
    );
    _correctAnswers = widget.question?.correctAnswers.toSet() ?? <int>{};
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleCorrectAnswer(int index) {
    setState(() {
      if (_correctAnswers.contains(index)) {
        _correctAnswers.remove(index);
      } else {
        _correctAnswers.add(index);
      }
    });
  }

  void _addQuestion() {
    final questionText = _questionController.text.trim();
    final options = _optionControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    
    if (questionText.isEmpty || options.length < 2 || _correctAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập câu hỏi, ít nhất 2 lựa chọn và chọn đáp án đúng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validCorrectAnswers = _correctAnswers
        .where((index) => index < options.length)
        .toList()..sort();

    final question = Question(
      question: questionText,
      options: options,
      correctAnswers: validCorrectAnswers,
    );

    widget.onAdd(question);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    widget.question == null ? 'Thêm câu hỏi' : 'Sửa câu hỏi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _questionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Nội dung câu hỏi',
                        hintText: 'Nhập câu hỏi của bạn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Các lựa chọn:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleCorrectAnswer(index),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _correctAnswers.contains(index)
                                        ? Colors.green
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  color: _correctAnswers.contains(index)
                                      ? Colors.green
                                      : Colors.transparent,
                                ),
                                child: _correctAnswers.contains(index)
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: 'Lựa chọn ${String.fromCharCode(65 + index)}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: _correctAnswers.contains(index)
                                      ? Colors.green[50]
                                      : Colors.grey[50],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nhấn vào vòng tròn để chọn đáp án đúng. Có thể chọn nhiều đáp án.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(widget.question == null ? 'Thêm' : 'Cập nhật'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}