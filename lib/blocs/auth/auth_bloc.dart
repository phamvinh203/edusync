import 'package:bloc/bloc.dart';
import 'package:edusync/blocs/auth/auth_event.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
	final AuthRepository repository;

	AuthBloc({required this.repository}) : super(const AuthState()) {
		on<AuthLoginRequested>(_onLogin);
		on<AuthLogoutRequested>(_onLogout);
		on<AuthRegisterRequested>(_onRegister);
	}

	Future<void> _onLogin(
		AuthLoginRequested event,
		Emitter<AuthState> emit,
	) async {
		emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
		try {
			final resp = await repository.login(
				email: event.email,
				password: event.password,
				rememberMe: event.rememberMe,
			);
			emit(state.copyWith(
				status: AuthStatus.authenticated,
				user: resp.data.user,
				accessToken: resp.data.accessToken,
				refreshToken: resp.data.refreshToken,
			));
		} catch (e) {
			emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString().replaceFirst('Exception: ', '')));
			emit(state.copyWith(status: AuthStatus.unauthenticated));
		}
	}

	Future<void> _onLogout(
		AuthLogoutRequested event,
		Emitter<AuthState> emit,
	) async {
			try {
				final userId = state.user?.id;
				if (userId != null && userId.isNotEmpty) {
					await repository.logout(userId: userId);
				}
			} catch (_) {
				// Không chặn logout nếu API lỗi
			} finally {
				emit(const AuthState(status: AuthStatus.unauthenticated));
			}
	}

		Future<void> _onRegister(
			AuthRegisterRequested event,
			Emitter<AuthState> emit,
		) async {
			emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
			try {
				final resp = await repository.register(
					username: event.username,
					email: event.email,
					password: event.password,
				);
				// Sau khi đăng ký thành công, giữ trạng thái unauthenticated và có thể đi tới Login
				emit(state.copyWith(
					status: AuthStatus.unauthenticated,
					user: resp.user,
				));
			} catch (e) {
				emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.toString().replaceFirst('Exception: ', '')));
			}
		}
}

