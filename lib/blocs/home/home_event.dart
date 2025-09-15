import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Lấy dữ liệu home lần đầu khi login
class LoadHome extends HomeEvent {
  final bool isTeacher;

  const LoadHome({required this.isTeacher});

  @override
  List<Object?> get props => [isTeacher];
}

/// Refresh thủ công (ví dụ khi kéo xuống refresh)
class RefreshHome extends HomeEvent {
  final bool isTeacher;

  const RefreshHome({required this.isTeacher});

  @override
  List<Object?> get props => [isTeacher];
}
