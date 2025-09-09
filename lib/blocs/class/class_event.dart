import 'package:edusync/models/class_model.dart';

abstract class ClassEvent {}

// Sự kiện load danh sách lớp học
class LoadClassesEvent extends ClassEvent {}

// Sự kiện thêm lớp học mới
class AddClassEvent extends ClassEvent {
  final String nameClass;
  final String subject;
  final String? description;
  final List<Schedule> schedule;
  final String? location;
  final int? maxStudents;

  AddClassEvent({
    required this.nameClass,
    required this.subject,
    this.description,
    required this.schedule,
    this.location,
    this.maxStudents,
  });
}

// Sự kiện thêm lớp học trực tiếp vào state (khi tạo thành công)
class ClassCreatedEvent extends ClassEvent {
  final ClassModel newClass;

  ClassCreatedEvent(this.newClass);
}

// Sự kiện refresh danh sách lớp học (gọi lại API)
class RefreshClassesEvent extends ClassEvent {}

// Sự kiện reset state
class ResetClassEvent extends ClassEvent {}

// Sự kiện load số lượng lớp đã đăng ký
class LoadRegisteredClassesCountEvent extends ClassEvent {}

// Sự kiện load danh sách lớp đã đăng ký của học sinh
class GetRegisteredClassesEvent extends ClassEvent {}

// Sự kiện đăng ký lớp học
class JoinClassEvent extends ClassEvent {
  final String classId;

  JoinClassEvent(this.classId);
}