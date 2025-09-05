import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc({required this.repository}) : super(const UserState()) {
    on<UserMeRequested>(_onLoadMe);
    on<UserAvatarUpdateRequested>(_onUpdateAvatar);
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

  Future<void> _onUpdateAvatar(
    UserAvatarUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    // Chỉ bật cờ upload để UI hiển thị spinner nhỏ trên avatar
    emit(state.copyWith(errorMessage: null, isUploadingAvatar: true));
    try {
      await repository.updateAvatarFromPath(event.filePath);
      // Sau khi upload xong, fetch lại thông tin người dùng để cập nhật avatar
      final me = await repository.getMe();
      emit(
        state.copyWith(
          status: UserStatus.loaded,
          auth: me.data.auth,
          profile: me.data.profile,
          isUploadingAvatar: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          // Không đẩy toàn màn hình sang failure; giữ dữ liệu hiện tại
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
          isUploadingAvatar: false,
        ),
      );
    }
  }
}
