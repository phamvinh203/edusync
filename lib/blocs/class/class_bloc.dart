import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/models/class_model.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassRepository _classRepository;
  List<ClassModel> _classes = [];

  ClassBloc({ClassRepository? classRepository})
    : _classRepository = classRepository ?? ClassRepository(),
      super(ClassInitial()) {
    // Debug: In ra để kiểm tra ClassBloc được khởi tạo
    print('ClassBloc initialized');

    // Xử lý sự kiện load danh sách lớp học
    on<LoadClassesEvent>((event, emit) async {
      print('LoadClassesEvent triggered');
      emit(ClassLoading());
      try {
        // Gọi API lấy danh sách lớp học từ server
        final classes = await _classRepository.getAllClasses();
        _classes = classes;
        emit(ClassLoaded(_classes));
      } catch (e) {
        emit(ClassError('Không thể tải danh sách lớp học: ${e.toString()}'));
      }
    });

    // Xử lý sự kiện tạo lớp học mới
    on<AddClassEvent>((event, emit) async {
      print('AddClassEvent triggered');
      emit(ClassLoading());
      try {
        final response = await _classRepository.createClass(
          nameClass: event.nameClass,
          subject: event.subject,
          description: event.description,
          schedule: event.schedule,
          location: event.location,
          maxStudents: event.maxStudents,
        );

        // Thêm lớp học mới vào danh sách local
        _classes.add(response.data);

        emit(
          ClassCreateSuccess(
            newClass: response.data,
            allClasses: List.from(_classes),
          ),
        );
      } catch (e) {
        emit(ClassError('Không thể tạo lớp học: ${e.toString()}'));
      }
    });

    // Xử lý sự kiện thêm lớp học trực tiếp (khi tạo từ màn hình khác)
    on<ClassCreatedEvent>((event, emit) {
      print('ClassCreatedEvent triggered');
      _classes.add(event.newClass);
      emit(ClassLoaded(List.from(_classes)));
    });

    // Xử lý sự kiện refresh danh sách lớp học
    on<RefreshClassesEvent>((event, emit) async {
      print('RefreshClassesEvent triggered');
      try {
        final classes = await _classRepository.getAllClasses();
        _classes = classes;
        emit(ClassLoaded(_classes));
      } catch (e) {
        emit(ClassError('Không thể tải danh sách lớp học: ${e.toString()}'));
      }
    });

    // Xử lý sự kiện reset
    on<ResetClassEvent>((event, emit) {
      print('ResetClassEvent triggered');
      _classes.clear();
      emit(ClassInitial());
    });
  }
}
