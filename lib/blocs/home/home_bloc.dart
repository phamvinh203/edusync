import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:edusync/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DashboardRepository homeRepository;

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    // Chỉ skip nếu đã có data cho đúng role
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // Skip nếu đã có data cho teacher và event cũng là teacher
      if (event.isTeacher && currentState.teacherHome != null) return;
      // Skip nếu đã có data cho student và event cũng là student
      if (!event.isTeacher && currentState.studentHome != null) return;
    }

    emit(HomeLoading());
    try {
      if (event.isTeacher) {
        final data = await homeRepository.getTeacherDashboard();
        emit(HomeLoaded(teacherHome: data));
      } else {
        final data = await homeRepository.getStudentDashboard();
        emit(HomeLoaded(studentHome: data));
      }
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
