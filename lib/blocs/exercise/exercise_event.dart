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

class LoadExerciseDetailEvent extends ExerciseEvent {
  final String classId;
  final String exerciseId;
  const LoadExerciseDetailEvent({
    required this.classId,
    required this.exerciseId,
  });

  @override
  List<Object?> get props => [classId, exerciseId];
}

class SubmitExerciseRequested extends ExerciseEvent {
  final String classId;
  final String exerciseId;
  final String? content;
  final MultipartFile? file;

  const SubmitExerciseRequested({
    required this.classId,
    required this.exerciseId,
    this.content,
    this.file,
  });

  @override
  List<Object?> get props => [classId, exerciseId, content, file];
}

class LoadExerciseSubmissionsEvent extends ExerciseEvent {
  final String classId;
  final String exerciseId;

  const LoadExerciseSubmissionsEvent({
    required this.classId,
    required this.exerciseId,
  });

  @override
  List<Object?> get props => [classId, exerciseId];
}

class UpdateSubmissionGradeEvent extends ExerciseEvent {
  final String classId;
  final String exerciseId;
  final String submissionId;
  final double grade;
  final String? feedback;

  UpdateSubmissionGradeEvent({
    required this.classId,
    required this.exerciseId,
    required this.submissionId,
    required this.grade,
    this.feedback,
  });

  @override
  List<Object?> get props => [
    classId,
    exerciseId,
    submissionId,
    grade,
    feedback,
  ];
}

class RedoSubmissionEvent extends ExerciseEvent {
  final String classId;
  final String exerciseId;
  final String? submissionId;

  RedoSubmissionEvent({
    required this.classId,
    required this.exerciseId,
    this.submissionId,
  });

  @override
  List<Object?> get props => [classId, exerciseId, submissionId];
}
