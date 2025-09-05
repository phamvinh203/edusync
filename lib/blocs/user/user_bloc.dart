import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const UserState()) {
    on<UserMeRequested>(_onLoadMe);
  }

  Future<void> _onLoadMe(UserMeRequested event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.loading, errorMessage: null));
    try {
      final resp = await repository.getMe();
      emit(
        state.copyWith(
          status: UserStatus.loaded,
          auth: resp.data.auth,
          profile: resp.data.profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
