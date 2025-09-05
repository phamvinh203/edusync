import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserMeRequested extends UserEvent {
  const UserMeRequested();
}

class UserAvatarUpdateRequested extends UserEvent {
  final String filePath;
  const UserAvatarUpdateRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class UserLogoutRequested extends UserEvent {
  const UserLogoutRequested();
}

class UserUpdateProfileRequested extends UserEvent {
  final String? username;
  final String? phone;
  final String? studentClass;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? email;

  const UserUpdateProfileRequested({
    this.username,
    this.phone,
    this.studentClass,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.email,
  });

  @override
  List<Object?> get props => [
        username,
        phone,
        studentClass,
        address,
        dateOfBirth,
        gender,
        email,
      ];
}
