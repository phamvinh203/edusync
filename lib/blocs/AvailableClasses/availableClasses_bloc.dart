import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/core/services/notification_manager.dart';
import 'package:edusync/models/class_model.dart';

import '../../repositories/class_repository.dart';
import 'availableClasses_event.dart';
import 'availableClasses_state.dart';

class AvailableClassesBloc
    extends Bloc<AvailableClassesEvent, AvailableClassesState> {
  final ClassRepository _classRepository;

  AvailableClassesBloc({required ClassRepository classRepository})
    : _classRepository = classRepository,
      super(AvailableClassesInitial()) {
    on<LoadAvailableClassesEvent>(_onLoad);
    on<RefreshAvailableClassesEvent>(_onRefresh);
    on<RegisterClassRequested>(_onRegister);
    on<CancelRegisterClassRequested>(_onCancel);
  }

  Future<void> _onLoad(
    LoadAvailableClassesEvent event,
    Emitter<AvailableClassesState> emit,
  ) async {
    // Luôn load dữ liệu mới từ server để đảm bảo cập nhật
    // Chỉ skip nếu đang loading để tránh multiple requests
    if (state is AvailableClassesLoading) return;

    emit(AvailableClassesLoading());
    try {
      final all = await _classRepository.getAllClasses();

      // Lọc các lớp có thể hiển thị: không bị xóa
      final available =
          all.where((c) {
            if (c.deleted == true) return false;
            return true;
          }).toList();

      // Lấy danh sách lớp đã đăng ký và đang chờ duyệt để cập nhật trạng thái đúng
      final registrationMap = await _buildRegistrationStatusMap(available);

      emit(
        AvailableClassesLoaded(
          classes: available,
          registrationStatus: registrationMap,
        ),
      );
    } catch (e) {
      // Khi lỗi, emit error state thay vì initial để user biết có lỗi
      emit(AvailableClassesInitial());
      print('Error loading available classes: $e');
    }
  }

  Future<void> _onRefresh(
    RefreshAvailableClassesEvent event,
    Emitter<AvailableClassesState> emit,
  ) async {
    emit(AvailableClassesLoading());
    try {
      final all = await _classRepository.getAllClasses();

      // Lọc các lớp có thể hiển thị: không bị xóa
      final available =
          all.where((c) {
            if (c.deleted == true) return false;
            return true;
          }).toList();

      // Lấy danh sách lớp đã đăng ký và đang chờ duyệt để cập nhật trạng thái đúng
      final registrationMap = await _buildRegistrationStatusMap(available);

      emit(
        AvailableClassesLoaded(
          classes: available,
          registrationStatus: registrationMap,
        ),
      );
    } catch (e) {
      emit(AvailableClassesInitial());
    }
  }
  

  /// Xây dựng map trạng thái đăng ký dựa trên dữ liệu thực tế từ server
  Future<Map<String, RegistrationStatus>> _buildRegistrationStatusMap(
    List<ClassModel> availableClasses,
  ) async {
    final registrationMap = <String, RegistrationStatus>{};

    try {
      // Lấy danh sách lớp đã đăng ký (đã được duyệt)
      final registeredClasses = await _classRepository.getMyRegisteredClasses();
      final registeredClassIds =
          registeredClasses
              .map((c) => c.id ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

      // Lấy danh sách lớp đang chờ duyệt
      final pendingClasses = await _classRepository.getMyPendingClasses();
      final pendingClassIds =
          pendingClasses
              .map((c) => c.id ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();

      // Cập nhật trạng thái cho từng lớp
      for (final classItem in availableClasses) {
        final classId = classItem.id ?? '';
        if (classId.isEmpty) continue;

        if (registeredClassIds.contains(classId)) {
          registrationMap[classId] = RegistrationStatus.registered;
        } else if (pendingClassIds.contains(classId)) {
          registrationMap[classId] = RegistrationStatus.pending;
        } else {
          registrationMap[classId] = RegistrationStatus.idle;
        }
      }
    } catch (e) {
      print('Error building registration status map: $e');
      // Fallback: set tất cả về idle nếu có lỗi
      for (var c in availableClasses) {
        registrationMap[c.id ?? ''] = RegistrationStatus.idle;
      }
    }

    return registrationMap;
  }

  Future<void> _onRegister(
    RegisterClassRequested event,
    Emitter<AvailableClassesState> emit,
  ) async {
    if (state is! AvailableClassesLoaded) return;
    final current = state as AvailableClassesLoaded;
    final id = event.classId;

    // Optimistic: set registering
    final reg1 = Map<String, RegistrationStatus>.from(
      current.registrationStatus,
    );
    reg1[id] = RegistrationStatus.registering;
    emit(current.copyWith(registrationStatus: reg1));

    try {
      final resp = await _classRepository.joinClass(id);

      // Decide final status:
      // If API returns "approved" you can set registered; otherwise pending.
      // Since repository's JoinClassResponse unknown here, we fallback to pending.
      final reg2 = Map<String, RegistrationStatus>.from(reg1);
      reg2[id] = RegistrationStatus.pending;
      emit(current.copyWith(registrationStatus: reg2));

      // Fire local notification to the student on successful registration request
      try {
        String className;
        String subject;
        try {
          final found = current.classes.firstWhere((c) => (c.id ?? '') == id);
          className = found.nameClass;
          subject = found.subject;
          // Also schedule reminders for this newly-registered class
          await NotificationManager().scheduleClassNotifications(
            classInfo: found,
          );
        } catch (_) {
          className = resp.data.className;
          subject = resp.data.subject;
        }
        await NotificationService().showClassRegistrationSuccessNotification(
          className: className,
          subject: subject,
        );
      } catch (_) {
        // non-fatal
      }
    } catch (e) {
      final reg3 = Map<String, RegistrationStatus>.from(
        current.registrationStatus,
      );
      reg3[id] = RegistrationStatus.failed;
      final errors = Map<String, String?>.from(current.errorMessages);
      errors[id] = e.toString();
      emit(current.copyWith(registrationStatus: reg3, errorMessages: errors));
      // Optionally revert to idle after some time or when user cancels/retries
    }
  }

  void _onCancel(
    CancelRegisterClassRequested event,
    Emitter<AvailableClassesState> emit,
  ) {
    if (state is! AvailableClassesLoaded) return;
    final current = state as AvailableClassesLoaded;
    final id = event.classId;
    final reg = Map<String, RegistrationStatus>.from(
      current.registrationStatus,
    );
    reg[id] = RegistrationStatus.idle;
    // Remove error message if any
    final errors = Map<String, String?>.from(current.errorMessages);
    errors.remove(id);
    emit(current.copyWith(registrationStatus: reg, errorMessages: errors));
  }

  
}
