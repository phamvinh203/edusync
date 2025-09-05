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
