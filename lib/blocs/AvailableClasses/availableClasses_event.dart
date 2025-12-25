abstract class AvailableClassesEvent {}

// Load (lần đầu hoặc force reload)
class LoadAvailableClassesEvent extends AvailableClassesEvent {
  final bool force;
  LoadAvailableClassesEvent({this.force = false});
}

// User requested refresh
class RefreshAvailableClassesEvent extends AvailableClassesEvent {}

// User bắt đầu đăng ký (optimistic)
class RegisterClassRequested extends AvailableClassesEvent {
  final String classId;
  RegisterClassRequested(this.classId);
}

// User hủy dialog / revert trạng thái
class CancelRegisterClassRequested extends AvailableClassesEvent {
  final String classId;
  CancelRegisterClassRequested(this.classId);
}
