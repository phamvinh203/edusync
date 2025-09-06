import 'package:edusync/models/class_model.dart';

abstract class ClassState {}

// State ban đầu
class ClassInitial extends ClassState {}

// State đang loading
class ClassLoading extends ClassState {}

// State load thành công
class ClassLoaded extends ClassState {
  final List<ClassModel> classes;

  ClassLoaded(this.classes);
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
