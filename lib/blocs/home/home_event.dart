import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Lấy dữ liệu home lần đầu hoặc khi refresh
class LoadHome extends HomeEvent {
  final bool isTeacher;

  const LoadHome({required this.isTeacher});

  @override
  List<Object?> get props => [isTeacher];
}
