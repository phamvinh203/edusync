import 'package:equatable/equatable.dart';
import 'package:edusync/models/exercise_model.dart';
import 'package:dio/dio.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  @override
  List<Object?> get props => [];
}

class CreateExerciseEvent extends ExerciseEvent {
  final String classId;
  final CreateExerciseRequest request;
  final List<MultipartFile>? files;

  const CreateExerciseEvent({
    required this.classId,
    required this.request,
    this.files,
  });

  @override
  List<Object?> get props => [classId, request, files];
}

class LoadExercisesByClassEvent extends ExerciseEvent {
  final String classId;
  const LoadExercisesByClassEvent(this.classId);

  @override
  List<Object?> get props => [classId];
}

class RefreshExercisesByClassEvent extends ExerciseEvent {
  final String classId;
  const RefreshExercisesByClassEvent(this.classId);

  @override
  List<Object?> get props => [classId];
}
