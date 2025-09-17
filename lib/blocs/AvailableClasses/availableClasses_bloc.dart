import 'package:flutter_bloc/flutter_bloc.dart';

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
    // Nếu đã load và không force thì giữ nguyên (avoid re-fetch)
    if (state is AvailableClassesLoaded && !event.force) return;

    emit(AvailableClassesLoading());
    try {
      final all = await _classRepository.getAllClasses();
      // Lọc chỉ các lớp "available" (còn chỗ) — bạn có thể thay đổi nếu muốn giữ tất cả
      final available =
          all.where((c) {
            final cur = c.students.length;
            final max = c.maxStudents ?? 0;
            return cur < max;
          }).toList();

      final registrationMap = <String, RegistrationStatus>{
        for (var c in available) (c.id ?? ''): RegistrationStatus.idle,
      };

      emit(
        AvailableClassesLoaded(
          classes: available,
          registrationStatus: registrationMap,
        ),
      );
    } catch (e) {
      // Khi lỗi, giữ initial (hoặc có thể emit error state nếu bạn muốn)
      emit(AvailableClassesInitial());
    }
  }

  Future<void> _onRefresh(
    RefreshAvailableClassesEvent event,
    Emitter<AvailableClassesState> emit,
  ) async {
    emit(AvailableClassesLoading());
    try {
      final all = await _classRepository.getAllClasses();
      final available =
          all.where((c) {
            final cur = c.students.length;
            final max = c.maxStudents ?? 0;
            return cur < max;
          }).toList();

      final registrationMap = <String, RegistrationStatus>{
        for (var c in available) (c.id ?? ''): RegistrationStatus.idle,
      };

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
      await _classRepository.joinClass(id);

      // Decide final status:
      // If API returns "approved" you can set registered; otherwise pending.
      // Since repository's JoinClassResponse unknown here, we fallback to pending.
      final reg2 = Map<String, RegistrationStatus>.from(reg1);
      reg2[id] = RegistrationStatus.pending;
      emit(current.copyWith(registrationStatus: reg2));
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
