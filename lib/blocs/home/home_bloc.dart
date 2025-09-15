import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:edusync/repositories/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DashboardRepository homeRepository;

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    on<LoadHome>(_onLoadHome);
    on<RefreshHome>(_onRefreshHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    // Nếu đang loading, bỏ qua để tránh gọi API trùng
    if (state is HomeLoading) return;

    // Nếu đã có data thì không load lại
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (event.isTeacher && currentState.teacherHome != null) return;
      if (!event.isTeacher && currentState.studentHome != null) return;
    }

    await _fetchData(event.isTeacher, emit);
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchData(event.isTeacher, emit);
  }

  Future<void> _fetchData(bool isTeacher, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      if (isTeacher) {
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
