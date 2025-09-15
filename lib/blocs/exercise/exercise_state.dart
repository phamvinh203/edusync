import 'package:equatable/equatable.dart';
import 'package:edusync/models/exercise_model.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();
  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseCreateSuccess extends ExerciseState {
  final ExerciseResponse response;
  const ExerciseCreateSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ExerciseError extends ExerciseState {
  final String message;
  const ExerciseError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExercisesLoading extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final List<Exercise> items;
  const ExercisesLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class ExerciseDetailLoading extends ExerciseState {}

class ExerciseDetailLoaded extends ExerciseState {
  final Exercise exercise;
  const ExerciseDetailLoaded(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class ExerciseSubmitting extends ExerciseState {}

class ExerciseSubmitSuccess extends ExerciseState {
  final SubmitExerciseResponse response;
  const ExerciseSubmitSuccess(this.response);

  @override
  List<Object?> get props => [response];
}
