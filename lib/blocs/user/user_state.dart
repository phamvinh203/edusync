import 'package:equatable/equatable.dart';
import 'package:edusync/models/users_model.dart';

enum UserStatus { initial, loading, loaded, failure }

class UserState extends Equatable {
  final UserStatus status;
  final MeAuth? auth; // auth.id, auth.email, auth.username
  final UserProfile? profile; // có thể null
  final String? errorMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.auth,
    this.profile,
    this.errorMessage,
  });

  UserState copyWith({
    UserStatus? status,
    MeAuth? auth,
    UserProfile? profile,
    String? errorMessage,
  }) => UserState(
    status: status ?? this.status,
    auth: auth ?? this.auth,
    profile: profile ?? this.profile,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, auth, profile, errorMessage];
}
