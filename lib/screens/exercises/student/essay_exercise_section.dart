// phần bài tập tự luận
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/screens/exercises/student/submit_exercise_screen.dart';
import 'package:edusync/l10n/app_localizations.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.edit_note, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.essayExercise,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final exerciseBloc = context.read<ExerciseBloc>();
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => BlocProvider.value(
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
            label: Text(AppLocalizations.of(context)!.submitExercise),
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
    );
  }
}
