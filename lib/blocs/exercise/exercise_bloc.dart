import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/exercise/exercise_event.dart';
import 'package:edusync/blocs/exercise/exercise_state.dart';
import 'package:edusync/repositories/exercise_repository.dart';

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
        emit(ExerciseCreateSuccess(resp));
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
  }
}
