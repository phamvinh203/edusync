import 'package:equatable/equatable.dart';
import 'package:edusync/models/class_model.dart';

abstract class RegisteredClassesState extends Equatable {
  const RegisteredClassesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RegisteredClassesInitial extends RegisteredClassesState {}

/// Loading registered/pending classes
class RegisteredClassesLoading extends RegisteredClassesState {}

/// Successfully loaded registered classes (approved by teacher)
class RegisteredClassesLoaded extends RegisteredClassesState {
  final List<ClassModel> registeredClasses;

  const RegisteredClassesLoaded(this.registeredClasses);

  @override
  List<Object?> get props => [registeredClasses];
}

/// Successfully loaded pending classes (waiting for approval)
class PendingClassesLoaded extends RegisteredClassesState {
  final List<ClassModel> pendingClasses;

  const PendingClassesLoaded(this.pendingClasses);

  @override
  List<Object?> get props => [pendingClasses];
}

/// Error loading registered/pending classes
class RegisteredClassesError extends RegisteredClassesState {
  final String message;

  const RegisteredClassesError(this.message);

  @override
  List<Object?> get props => [message];
}
