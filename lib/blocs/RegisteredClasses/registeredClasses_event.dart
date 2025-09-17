import 'package:equatable/equatable.dart';
import 'package:edusync/models/class_model.dart';

abstract class RegisteredClassesEvent extends Equatable {
  const RegisteredClassesEvent();

  @override
  List<Object?> get props => [];
}

// Load lần đầu khi login
class LoadRegisteredClassesEvent extends RegisteredClassesEvent {}

// Refresh khi cần (ví dụ sau khi tạo/xoá/đăng ký thành công)
class RefreshRegisteredClassesEvent extends RegisteredClassesEvent {}

// Thêm lớp đã đăng ký vào danh sách (sau khi JoinClass thành công)
class AddRegisteredClassEvent extends RegisteredClassesEvent {
  final ClassModel newClass;
  const AddRegisteredClassEvent(this.newClass);

  @override
  List<Object?> get props => [newClass];
}
