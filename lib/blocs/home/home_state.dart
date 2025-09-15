import 'package:equatable/equatable.dart';
import 'package:edusync/models/home_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final StudentDashboard? studentHome;
  final TeacherDashboard? teacherHome;

  const HomeLoaded({
    this.studentHome,
    this.teacherHome,
  });

  @override
  List<Object?> get props => [studentHome ?? '', teacherHome ?? ''];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
