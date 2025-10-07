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
    final maxScore = widget.exercise.maxScore ?? 10.0; // ✅ luôn lấy 10 nếu null
    final pointPerQuestion = maxScore / totalQ; // ✅ mỗi câu bao nhiêu điểm

    int correctCount = 0;
    double earnedWeight = 0;

    for (int i = 0; i < totalQ; i++) {
      final picked = _selected[i].toList()..sort();
      final correct = [...questions[i].correctAnswers]..sort();
      final isCorrect =
          picked.length == correct.length &&
          picked.every((e) => correct.contains(e));

      if (isCorrect) {
        correctCount++;
        earnedWeight += pointPerQuestion; // ✅ cộng điểm chia đều
      }
    }

    final score = earnedWeight;

    setState(() => _submitting = true);
    try {
      final repo = ExerciseRepository();
      final answersPerQuestion = _selected.map((s) => s.toList()).toList();
      final flatAnswers =
          answersPerQuestion
              .map((ans) => ans.isNotEmpty ? ans.first : -1)
              .toList();
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

      await repo.submitExercise(
        classId: widget.classId,
        exerciseId: widget.exerciseId,
        content: summary.toString(),
        answers: flatAnswers,
      );

      widget.onSubmitted?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi nộp bài: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Làm bài trắc nghiệm',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ex.questions.length,
          separatorBuilder: (_, __) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final q = ex.questions[index];
            final multiple = _isMultipleSelect(index);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu ${index + 1}: ${q.question}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                ...List.generate(q.options.length, (optIdx) {
                  final selected = _selected[index].contains(optIdx);
                  if (multiple) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
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
                    );
                  } else {
                    return RadioListTile<int>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
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
                    );
                  }
                }),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon:
                _submitting
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.send),
            label: const Text('Nộp bài'),
          ),
        ),
      ],
    );
  }
}
