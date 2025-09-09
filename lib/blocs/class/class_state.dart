import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

abstract class ClassState {}

// State ban đầu
class ClassInitial extends ClassState {}

// State đang loading
class ClassLoading extends ClassState {}

// State load thành công
class ClassLoaded extends ClassState {
  final List<ClassModel> classes;
  final int registeredClassesCount; // Thêm số lượng lớp đã đăng ký

  ClassLoaded(this.classes, {this.registeredClassesCount = 0});
}

// State khi tạo lớp học thành công
class ClassCreateSuccess extends ClassState {
  final ClassModel newClass;
  final List<ClassModel> allClasses;

  ClassCreateSuccess({required this.newClass, required this.allClasses});
}

// State lỗi
class ClassError extends ClassState {
  final String message;

  ClassError(this.message);
}

// State đang đăng ký lớp học
class ClassJoining extends ClassState {}

// State đăng ký lớp học thành công
class ClassJoinSuccess extends ClassState {
  final JoinClassResponse response;
  final bool success;  // THÊM: Dựa trên response.success hoặc true nếu join OK

  ClassJoinSuccess(this.response) : success = response.success ?? true;  
}

// State đăng ký lớp học thất bại
class ClassJoinError extends ClassState {
  final String message;

  ClassJoinError(this.message);
}
