import 'package:equatable/equatable.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

abstract class AvailableClassesState extends Equatable {
  const AvailableClassesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AvailableClassesInitial extends AvailableClassesState {}

/// Loading available classes
class AvailableClassesLoading extends AvailableClassesState {}

/// Successfully loaded available classes
class AvailableClassesLoaded extends AvailableClassesState {
  final List<ClassModel> availableClasses;

  const AvailableClassesLoaded(this.availableClasses);

  @override
  List<Object?> get props => [availableClasses];
}

/// Error loading available classes
class AvailableClassesError extends AvailableClassesState {
  final String message;

  const AvailableClassesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Currently registering for a class
class RegisteringForClass extends AvailableClassesState {}

/// Successfully registered for a class
class ClassRegistrationSuccess extends AvailableClassesState {
  final JoinClassResponse response;

  const ClassRegistrationSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// Failed to register for a class
class ClassRegistrationError extends AvailableClassesState {
  final String message;

  const ClassRegistrationError(this.message);

  @override
  List<Object?> get props => [message];
}
