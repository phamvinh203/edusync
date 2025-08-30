import 'package:equatable/equatable.dart';
import 'package:edusync/models/auth_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
	final AuthStatus status;
	final AuthUser? user;
	final String? accessToken;
	final String? refreshToken;
	final String? errorMessage;

	const AuthState({
		this.status = AuthStatus.initial,
		this.user,
		this.accessToken,
		this.refreshToken,
		this.errorMessage,
	});

	AuthState copyWith({
		AuthStatus? status,
		AuthUser? user,
		String? accessToken,
		String? refreshToken,
		String? errorMessage,
	}) {
		return AuthState(
			status: status ?? this.status,
			user: user ?? this.user,
			accessToken: accessToken ?? this.accessToken,
			refreshToken: refreshToken ?? this.refreshToken,
			errorMessage: errorMessage,
		);
	}

	@override
	List<Object?> get props => [status, user, accessToken, refreshToken, errorMessage];
}

