import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/available_classes/available_classes_event.dart';
import 'package:edusync/blocs/available_classes/available_classes_state.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/models/class_model.dart';

class AvailableClassesBloc
    extends Bloc<AvailableClassesEvent, AvailableClassesState> {
  final ClassRepository _classRepository;
  final String? _currentUserId;
  List<ClassModel> _cachedClasses = [];

  AvailableClassesBloc({
    ClassRepository? classRepository,
    String? currentUserId,
  }) : _classRepository = classRepository ?? ClassRepository(),
       _currentUserId = currentUserId,
       super(AvailableClassesInitial()) {
    // Load available classes (with caching)
    on<LoadAvailableClassesEvent>((event, emit) async {
      // Skip if already loading
      if (state is AvailableClassesLoading) return;

      // Use cache if available
      if (_cachedClasses.isNotEmpty) {
        emit(AvailableClassesLoaded(List.from(_cachedClasses)));
        return;
      }

      emit(AvailableClassesLoading());
      try {
        final allClasses = await _classRepository.getAllClasses();

        // Filter to only show classes that have available spots AND user hasn't joined
        final availableClasses =
            allClasses.where((classItem) {
              final currentStudents = classItem.students.length;
              final maxStudents = classItem.maxStudents ?? 0;
              final hasAvailableSpots = currentStudents < maxStudents;

              // Kiểm tra user hiện tại chưa tham gia lớp này (chưa được duyệt)
              final isUserAlreadyJoined =
                  _currentUserId != null &&
                  classItem.students.contains(_currentUserId);

              return hasAvailableSpots && !isUserAlreadyJoined;
            }).toList();

        _cachedClasses = availableClasses;
        emit(AvailableClassesLoaded(availableClasses));
      } catch (e) {
        emit(
          AvailableClassesError(
            'Không thể tải danh sách lớp gia sư: ${e.toString()}',
          ),
        );
      }
    });

    // Refresh available classes (force reload)
    on<RefreshAvailableClassesEvent>((event, emit) async {
      _cachedClasses.clear(); // Clear cache to force reload
      emit(AvailableClassesLoading());

      try {
        final allClasses = await _classRepository.getAllClasses();

        // Filter to only show classes that have available spots AND user hasn't joined
        final availableClasses =
            allClasses.where((classItem) {
              final currentStudents = classItem.students.length;
              final maxStudents = classItem.maxStudents ?? 0;
              final hasAvailableSpots = currentStudents < maxStudents;

              // Kiểm tra user hiện tại chưa tham gia lớp này (chưa được duyệt)
              final isUserAlreadyJoined =
                  _currentUserId != null &&
                  classItem.students.contains(_currentUserId);

              return hasAvailableSpots && !isUserAlreadyJoined;
            }).toList();

        _cachedClasses = availableClasses;
        emit(AvailableClassesLoaded(availableClasses));
      } catch (e) {
        emit(
          AvailableClassesError(
            'Không thể tải danh sách lớp gia sư: ${e.toString()}',
          ),
        );
      }
    });

    // Register for a class
    on<RegisterForClassEvent>((event, emit) async {
      emit(RegisteringForClass());
      try {
        final response = await _classRepository.joinClass(event.classId);
        emit(ClassRegistrationSuccess(response));

        // Refresh the available classes after successful registration
        add(RefreshAvailableClassesEvent());
      } catch (e) {
        emit(
          ClassRegistrationError('Không thể đăng ký lớp học: ${e.toString()}'),
        );
      }
    });
  }
}
