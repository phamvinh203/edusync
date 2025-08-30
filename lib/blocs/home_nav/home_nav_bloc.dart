import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Sự kiện chọn tab
abstract class HomeNavEvent extends Equatable {
  const HomeNavEvent();
  @override
  List<Object?> get props => [];
}

class HomeTabSelected extends HomeNavEvent {
  final int index;
  const HomeTabSelected(this.index);
  @override
  List<Object?> get props => [index];
}

// State chỉ lưu currentIndex
class HomeNavState extends Equatable {
  final int currentIndex;
  const HomeNavState({required this.currentIndex});

  HomeNavState copyWith({int? currentIndex}) =>
      HomeNavState(currentIndex: currentIndex ?? this.currentIndex);

  @override
  List<Object?> get props => [currentIndex];
}

// Bloc điều hướng bottom nav
class HomeNavBloc extends Bloc<HomeNavEvent, HomeNavState> {
  HomeNavBloc() : super(const HomeNavState(currentIndex: 0)) {
    on<HomeTabSelected>((event, emit) =>
        emit(state.copyWith(currentIndex: event.index)));
  }
}
