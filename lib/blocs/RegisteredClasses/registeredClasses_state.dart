import 'package:equatable/equatable.dart';
import 'package:edusync/models/class_model.dart';

abstract class RegisteredClassesState extends Equatable {
  const RegisteredClassesState();

  @override
  List<Object?> get props => [];
}

class RegisteredClassesInitial extends RegisteredClassesState {}

class RegisteredClassesLoading extends RegisteredClassesState {}

class RegisteredClassesLoaded extends RegisteredClassesState {
  final List<ClassModel> registeredClasses;
  const RegisteredClassesLoaded(this.registeredClasses);

  @override
  List<Object?> get props => [registeredClasses];

  get classes => null;
}

class RegisteredClassesError extends RegisteredClassesState {
  final String message;
  const RegisteredClassesError(this.message);

  @override
  List<Object?> get props => [message];
}
