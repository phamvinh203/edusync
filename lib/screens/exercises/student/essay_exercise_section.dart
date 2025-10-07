// phần bài tập tự luận
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/screens/exercises/student/submit_exercise_screen.dart';

class EssayExerciseSection extends StatelessWidget {
  final String classId;
  final String exerciseId;
  final VoidCallback? onSubmitted;

  const EssayExerciseSection({
    super.key,
    required this.classId,
    required this.exerciseId,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final exerciseBloc = context.read<ExerciseBloc>();
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: exerciseBloc,
                child: SubmitExerciseScreen(
                  classId: classId,
                  exerciseId: exerciseId,
                ),
              ),
            ),
          );
          if (result == true) {
            onSubmitted?.call();
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Nộp bài'),
      ),
    );
  }
}