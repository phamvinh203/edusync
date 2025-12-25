import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_event.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_state.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/models/class_model.dart';

class RegisteredClassesBloc
    extends Bloc<RegisteredClassesEvent, RegisteredClassesState> {
  final ClassRepository _classRepository;
  List<ClassModel> _cachedRegisteredClasses = [];
  List<ClassModel> _cachedPendingClasses = [];

  RegisteredClassesBloc({ClassRepository? classRepository})
    : _classRepository = classRepository ?? ClassRepository(),
      super(RegisteredClassesInitial()) {
    // Load registered classes (approved by teacher)
    on<LoadRegisteredClassesEvent>((event, emit) async {
      // Skip if already loading
      if (state is RegisteredClassesLoading) return;

      // Use cache if available
      if (_cachedRegisteredClasses.isNotEmpty) {
        emit(RegisteredClassesLoaded(List.from(_cachedRegisteredClasses)));
        return;
      }

      emit(RegisteredClassesLoading());
      try {
        final registeredClasses =
            await _classRepository.getMyRegisteredClasses();
        _cachedRegisteredClasses = registeredClasses;
        emit(RegisteredClassesLoaded(registeredClasses));
      } catch (e) {
        emit(
          RegisteredClassesError(
            'Không thể tải danh sách lớp đã đăng ký: ${e.toString()}',
          ),
        );
      }
    });

    // Refresh registered classes (force reload)
    on<RefreshRegisteredClassesEvent>((event, emit) async {
      _cachedRegisteredClasses.clear(); // Clear cache to force reload
      emit(RegisteredClassesLoading());

      try {
        final registeredClasses =
            await _classRepository.getMyRegisteredClasses();
        _cachedRegisteredClasses = registeredClasses;
        emit(RegisteredClassesLoaded(registeredClasses));
      } catch (e) {
        emit(
          RegisteredClassesError(
            'Không thể tải danh sách lớp đã đăng ký: ${e.toString()}',
          ),
        );
      }
    });

    // Load pending classes (waiting for teacher approval)
    on<LoadPendingClassesEvent>((event, emit) async {
      // Skip if already loading
      if (state is RegisteredClassesLoading) return;

      // Use cache if available
      if (_cachedPendingClasses.isNotEmpty) {
        emit(PendingClassesLoaded(List.from(_cachedPendingClasses)));
        return;
      }

      emit(RegisteredClassesLoading());
      try {
        final pendingClasses = await _classRepository.getMyPendingClasses();
        _cachedPendingClasses = pendingClasses;
        emit(PendingClassesLoaded(pendingClasses));
      } catch (e) {
        emit(
          RegisteredClassesError(
            'Không thể tải danh sách lớp đang chờ duyệt: ${e.toString()}',
          ),
        );
      }
    });
  }
}
