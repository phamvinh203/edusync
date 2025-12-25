import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/core/services/notification_manager.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final ExerciseRepository _repo;

  ExerciseBloc({ExerciseRepository? repository})
    : _repo = repository ?? ExerciseRepository(),
      super(ExerciseInitial()) {
    on<CreateExerciseEvent>((event, emit) async {
      emit(ExerciseLoading());
      try {
        final resp = await _repo.createExercise(
          classId: event.classId,
          payload: event.request,
          files: event.files,
        );

        // Emit success immediately so UI can proceed
        emit(ExerciseCreateSuccess(resp));

        // Fire-and-forget notifications to avoid blocking UI
        // ignore: unawaited_futures
        (() async {
          try {
            await NotificationService().showAssignmentCreatedNotification(
              assignmentTitle: event.request.title,
              className: 'Lớp học', // Optionally pass actual class name
            );
            await NotificationManager().notifyStudentsAboutNewAssignment(
              classId: event.classId,
              exercise: resp.data,
              teacherName: 'Giáo viên', // Optionally pass real teacher name
            );
          } catch (_) {
            // Swallow notification errors
          }
        })();
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<LoadExercisesByClassEvent>((event, emit) async {
      emit(ExercisesLoading());
      try {
        final items = await _repo.getExercisesByClass(event.classId);
        emit(ExercisesLoaded(items));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<RefreshExercisesByClassEvent>((event, emit) async {
      try {
        final items = await _repo.getExercisesByClass(event.classId);
        emit(ExercisesLoaded(items));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<LoadExerciseDetailEvent>((event, emit) async {
      emit(ExerciseDetailLoading());
      try {
        final ex = await _repo.getExerciseDetails(
          classId: event.classId,
          exerciseId: event.exerciseId,
        );
        emit(ExerciseDetailLoaded(ex));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<SubmitExerciseRequested>((event, emit) async {
      emit(ExerciseSubmitting());
      try {
        final resp = await _repo.submitExercise(
          classId: event.classId,
          exerciseId: event.exerciseId,
          content: event.content,
          file: event.file,
        );
        emit(ExerciseSubmitSuccess(resp));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<LoadExerciseSubmissionsEvent>((event, emit) async {
      emit(ExerciseSubmissionsLoading());
      try {
        final subs = await _repo.getSubmissions(
          classId: event.classId,
          exerciseId: event.exerciseId,
        );
        emit(ExerciseSubmissionsLoaded(subs));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<UpdateSubmissionGradeEvent>((event, emit) async {
      try {
        await _repo.gradeSubmission(
          classId: event.classId,
          exerciseId: event.exerciseId,
          submissionId: event.submissionId,
          grade: event.grade,
          feedback: event.feedback,
        );
        // Reload exercise details to reflect updated grades
        final ex = await _repo.getExerciseDetails(
          classId: event.classId,
          exerciseId: event.exerciseId,
        );
        emit(ExerciseDetailLoaded(ex));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });

    on<RedoSubmissionEvent>((event, emit) async {
      try {
        if (event.submissionId == null || event.submissionId!.isEmpty) {
          throw Exception('Submission id is missing');
        }

        // Delete existing submission
        await _repo.deleteSubmission(
          classId: event.classId,
          exerciseId: event.exerciseId,
          submissionId: event.submissionId!,
        );

        // Reload exercise details so UI reflects no submission
        final ex = await _repo.getExerciseDetails(
          classId: event.classId,
          exerciseId: event.exerciseId,
        );
        emit(ExerciseDetailLoaded(ex));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    });
  }
}
