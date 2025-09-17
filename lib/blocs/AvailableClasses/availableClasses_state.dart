import 'package:edusync/models/class_model.dart';

enum RegistrationStatus { idle, registering, pending, registered, failed }

abstract class AvailableClassesState {}

class AvailableClassesInitial extends AvailableClassesState {}

class AvailableClassesLoading extends AvailableClassesState {}

// Lưu toàn bộ danh sách classes + trạng thái đăng ký cho từng classId
class AvailableClassesLoaded extends AvailableClassesState {
  final List<ClassModel> classes;
  final Map<String, RegistrationStatus> registrationStatus;
  final Map<String, String?> errorMessages;

  AvailableClassesLoaded({
    required this.classes,
    Map<String, RegistrationStatus>? registrationStatus,
    Map<String, String?>? errorMessages,
  })  : registrationStatus = registrationStatus ??
      {for (var c in classes) (c.id ?? ''): RegistrationStatus.idle},
        errorMessages = errorMessages ?? {};

  AvailableClassesLoaded copyWith({
    List<ClassModel>? classes,
    Map<String, RegistrationStatus>? registrationStatus,
    Map<String, String?>? errorMessages,
  }) {
    return AvailableClassesLoaded(
      classes: classes ?? this.classes,
      registrationStatus: registrationStatus ?? Map.from(this.registrationStatus),
      errorMessages: errorMessages ?? Map.from(this.errorMessages),
    );
  }
}
