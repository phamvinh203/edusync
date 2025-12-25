import 'package:equatable/equatable.dart';

abstract class AvailableClassesEvent extends Equatable {
  const AvailableClassesEvent();

  @override
  List<Object?> get props => [];
}

/// Load available classes that students can register for
class LoadAvailableClassesEvent extends AvailableClassesEvent {}

/// Refresh available classes (force reload from server)
class RefreshAvailableClassesEvent extends AvailableClassesEvent {}

/// Register for a specific class
class RegisterForClassEvent extends AvailableClassesEvent {
  final String classId;

  const RegisterForClassEvent(this.classId);

  @override
  List<Object?> get props => [classId];
}
