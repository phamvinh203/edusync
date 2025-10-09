// phần bài tập trắc nghiệm
import 'package:flutter/material.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:edusync/repositories/exercise_repository.dart';

class McqExerciseSection extends StatefulWidget {
  final Exercise exercise;
  final String classId;
  final String exerciseId;
  final VoidCallback? onSubmitted;

  const McqExerciseSection({
    super.key,
    required this.exercise,
    required this.classId,
    required this.exerciseId,
    this.onSubmitted,
  });

  @override
  State<McqExerciseSection> createState() => _McqExerciseSectionState();
}

class _McqExerciseSectionState extends State<McqExerciseSection> {
  late List<Set<int>> _selected;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = List.generate(widget.exercise.questions.length, (_) => <int>{});
  }

  bool _isMultipleSelect(int qIndex) {
    final correct = widget.exercise.questions[qIndex].correctAnswers;
    return correct.length > 1;
  }

  Future<void> _submit() async {
    // Kiểm tra tất cả câu hỏi đã được trả lời
    for (var s in _selected) {
      if (s.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng trả lời tất cả câu hỏi')),
        );
        return;
      }
    }

    final questions = widget.exercise.questions;
    final totalQ = questions.length;
    final maxScore = widget.exercise.maxScore ?? 10.0;
    final pointPerQuestion = maxScore / totalQ;

    int correctCount = 0;
    double earnedWeight = 0;

    // Tính điểm
    for (int i = 0; i < totalQ; i++) {
      final picked = _selected[i].toList()..sort();
      final correct = [...questions[i].correctAnswers]..sort();
      final isCorrect =
          picked.length == correct.length &&
          picked.every((e) => correct.contains(e));

      if (isCorrect) {
        correctCount++;
        earnedWeight += pointPerQuestion;
      }
    }

    final score = earnedWeight;

    setState(() => _submitting = true);
    try {
      final repo = ExerciseRepository();
      final answersPerQuestion = _selected.map((s) => s.toList()).toList();

      // Tạo danh sách câu trả lời phẳng để gửi lên server
      final flatAnswers =
          answersPerQuestion
              .map((ans) => ans.isNotEmpty ? ans.first : -1)
              .toList();

      // Tạo nội dung tóm tắt
      final summary = StringBuffer();
      summary.writeln('Bài làm trắc nghiệm');
      summary.writeln('Số câu đúng: $correctCount/$totalQ');
      summary.writeln(
        'Điểm: ${score.toStringAsFixed(2)}${widget.exercise.maxScore != null ? ' / ${widget.exercise.maxScore}' : ''}',
      );
      for (int i = 0; i < questions.length; i++) {
        summary.writeln(
          'Câu ${i + 1}: chọn ${answersPerQuestion[i].map((x) => x + 1).join(', ')}',
        );
      }

      // Gửi bài lên server
      await repo.submitExercise(
        classId: widget.classId,
        exerciseId: widget.exerciseId,
        content: summary.toString(),
        answers: flatAnswers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nộp bài thành công! Điểm: ${score.toStringAsFixed(1)}/$maxScore',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Gọi callback để reload dữ liệu
        widget.onSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nộp bài: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;

    // Kiểm tra có câu hỏi không
    if (ex.questions.isEmpty) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.orange[300]),
              const SizedBox(height: 12),
              const Text(
                'Bài tập trắc nghiệm chưa có câu hỏi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.quiz, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Làm bài trắc nghiệm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              Chip(
                label: Text('${ex.questions.length} câu'),
                backgroundColor: Colors.purple.withOpacity(0.2),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ex.questions.length,
          separatorBuilder: (_, __) => const Divider(height: 24, thickness: 1),
          itemBuilder: (context, index) {
            final q = ex.questions[index];
            final multiple = _isMultipleSelect(index);
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Câu ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (multiple) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Nhiều đáp án',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(q.options.length, (optIdx) {
                      final selected = _selected[index].contains(optIdx);
                      if (multiple) {
                        return CheckboxListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          value: selected,
                          title: Text(q.options[optIdx]),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected[index].add(optIdx);
                              } else {
                                _selected[index].remove(optIdx);
                              }
                            });
                          },
                          activeColor: Colors.purple,
                        );
                      } else {
                        return RadioListTile<int>(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          value: optIdx,
                          groupValue:
                              _selected[index].isEmpty
                                  ? null
                                  : _selected[index].first,
                          title: Text(q.options[optIdx]),
                          onChanged: (v) {
                            setState(() {
                              _selected[index]
                                ..clear()
                                ..add(v!);
                            });
                          },
                          activeColor: Colors.purple,
                        );
                      }
                    }),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon:
                _submitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.send),
            label: Text(_submitting ? 'Đang nộp bài...' : 'Nộp bài'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.purple,
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
    );
  }
}
