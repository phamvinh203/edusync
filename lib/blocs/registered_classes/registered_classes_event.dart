import 'package:equatable/equatable.dart';

abstract class RegisteredClassesEvent extends Equatable {
  const RegisteredClassesEvent();

  @override
  List<Object?> get props => [];
}

/// Load classes that the student has been approved to join
class LoadRegisteredClassesEvent extends RegisteredClassesEvent {}

/// Refresh registered classes (force reload from server)
class RefreshRegisteredClassesEvent extends RegisteredClassesEvent {}

/// Load pending classes (waiting for teacher approval)
class LoadPendingClassesEvent extends RegisteredClassesEvent {}
