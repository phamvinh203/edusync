import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
	const AuthEvent();

	@override
	List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
	final String email;
	final String password;
	final bool rememberMe;

	const AuthLoginRequested({
		required this.email,
		required this.password,
		required this.rememberMe,
	});

	@override
	List<Object?> get props => [email, password, rememberMe];
}

class AuthLogoutRequested extends AuthEvent {
	const AuthLogoutRequested();
}

class AuthRegisterRequested extends AuthEvent {
	final String username;
	final String email;
	final String password;

	const AuthRegisterRequested({
		required this.username,
		required this.email,
		required this.password,
	});

	@override
	List<Object?> get props => [username, email, password];
}

