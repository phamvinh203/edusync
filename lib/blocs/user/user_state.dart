import 'package:equatable/equatable.dart';
import 'package:edusync/models/users_model.dart';

enum UserStatus {
  initial,
  loading,
  loaded,
  failure,
  logoutSuccess,
  logoutFailure,
}

class UserState extends Equatable {
  final UserStatus status;
  final MeAuth? auth; // auth.id, auth.email, auth.username
  final UserProfile? profile; // có thể null
  final String? errorMessage;
  final bool isUploadingAvatar;
  final bool isUpdatingProfile;
  final String? successMessage;

  const UserState({
    this.status = UserStatus.initial,
    this.auth,
    this.profile,
    this.errorMessage,
    this.isUploadingAvatar = false,
    this.isUpdatingProfile = false,
    this.successMessage,
  });

  UserState copyWith({
    UserStatus? status,
    MeAuth? auth,
    UserProfile? profile,
    String? errorMessage,
    bool? isUploadingAvatar,
    bool? isUpdatingProfile,
    String? successMessage,
  }) => UserState(
    status: status ?? this.status,
    auth: auth ?? this.auth,
    profile: profile ?? this.profile,
    errorMessage: errorMessage,
    isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
    successMessage: successMessage ?? this.successMessage,
  );

  @override
  List<Object?> get props => [
    status,
    auth,
    profile,
    errorMessage,
    isUploadingAvatar,
    isUpdatingProfile,
    successMessage,
  ];
}
