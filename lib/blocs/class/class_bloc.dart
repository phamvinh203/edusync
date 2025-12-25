import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/core/services/notification_service.dart';

class ClassBloc extends Bloc<ClassEvent, ClassState> {
  final ClassRepository _classRepository;
  List<ClassModel> _classes = [];
  int _registeredClassesCount = 0; // Thêm biến lưu số lượng lớp đã đăng ký

  ClassBloc({ClassRepository? classRepository})
    : _classRepository = classRepository ?? ClassRepository(),
      super(ClassInitial()) {
    // Debug: In ra để kiểm tra ClassBloc được khởi tạo
    print('ClassBloc initialized');

    // Xử lý sự kiện load danh sách lớp học
    on<LoadClassesEvent>((event, emit) async {
      print('LoadClassesEvent triggered');
      // Nếu đang loading thì bỏ qua để tránh gọi API trùng
      if (state is ClassLoading) return;

      // Nếu đã có cache thì dùng lại, không gọi API
      if (_classes.isNotEmpty) {
        emit(
          ClassLoaded(
            List.from(_classes),
            registeredClassesCount: _registeredClassesCount,
          ),
        );
        return;
      }

      emit(ClassLoading());
      try {
        // Gọi API lấy danh sách lớp học từ server
        final allClasses = await _classRepository.getAllClasses();

        // Chỉ lấy các lớp học thêm (type='extra') cho tab "Lớp gia sư"
        final classes =
            allClasses.where((c) => c.type.toLowerCase() == 'extra').toList();

        _classes = classes;
        emit(
          ClassLoaded(
            _classes,
            registeredClassesCount: _registeredClassesCount,
          ),
        );
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

        // Show notification for successful class creation (Teacher)
        await NotificationService().showClassCreatedNotification(
          className: event.nameClass,
          subject: event.subject,
        );

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
      emit(
        ClassLoaded(
          List.from(_classes),
          registeredClassesCount: _registeredClassesCount,
        ),
      );
    });

    // Xử lý sự kiện load số lượng lớp đã đăng ký
    on<LoadRegisteredClassesCountEvent>((event, emit) async {
      print('LoadRegisteredClassesCountEvent triggered');
      try {
        // Sử dụng getMyRegisteredClasses() để đảm bảo chỉ đếm lớp đã được duyệt
        final allRegisteredClasses =
            await _classRepository.getMyRegisteredClasses();

        // Chỉ đếm các lớp học thêm (type='extra') cho tab "Lớp gia sư"
        final registeredExtraClasses =
            allRegisteredClasses
                .where((c) => c.type.toLowerCase() == 'extra')
                .toList();

        _registeredClassesCount = registeredExtraClasses.length;
        // Cập nhật lại state hiện tại với số lượng mới
        if (state is ClassLoaded) {
          final currentState = state as ClassLoaded;
          emit(
            ClassLoaded(
              currentState.classes,
              registeredClassesCount: _registeredClassesCount,
            ),
          );
        }
      } catch (e) {
        print('Error loading registered classes count: ${e.toString()}');
        // Không emit error để không làm gián đoạn UI, chỉ log lỗi
      }
    });

    // Xử lý sự kiện refresh danh sách lớp học
    on<RefreshClassesEvent>((event, emit) async {
      print('RefreshClassesEvent triggered');
      try {
        final allClasses = await _classRepository.getAllClasses();

        // Chỉ lấy các lớp học thêm (type='extra') cho tab "Lớp gia sư"
        final classes =
            allClasses.where((c) => c.type.toLowerCase() == 'extra').toList();

        _classes = classes;
        emit(
          ClassLoaded(
            _classes,
            registeredClassesCount: _registeredClassesCount,
          ),
        );
      } catch (e) {
        emit(ClassError('Không thể tải danh sách lớp học: ${e.toString()}'));
      }
    });

    // Xử lý sự kiện load danh sách lớp đã đăng ký của học sinh
    on<GetRegisteredClassesEvent>((event, emit) async {
      // print('GetRegisteredClassesEvent triggered');
      emit(ClassLoading());
      try {
        final allRegisteredClasses =
            await _classRepository.getMyRegisteredClasses();

        // Chỉ lấy các lớp học thêm (type='extra') cho tab "Lớp gia sư"
        final classes =
            allRegisteredClasses
                .where((c) => c.type.toLowerCase() == 'extra')
                .toList();

        _classes = classes; // Cập nhật cache
        _registeredClassesCount = classes.length; // Cập nhật số lượng đúng
        emit(
          ClassLoaded(classes, registeredClassesCount: _registeredClassesCount),
        );
      } catch (e) {
        emit(
          ClassError('Không thể tải danh sách lớp đã đăng ký: ${e.toString()}'),
        );
      }
    });

    // Xử lý sự kiện load danh sách lớp đang chờ phê duyệt
    on<GetPendingClassesEvent>((event, emit) async {
      print('GetPendingClassesEvent triggered');
      emit(ClassLoading());
      try {
        final allPendingClasses = await _classRepository.getMyPendingClasses();
        // Chỉ lấy các lớp học thêm (type='extra') cho tab "Lớp gia sư"
        final classes =
            allPendingClasses
                .where((c) => c.type.toLowerCase() == 'extra')
                .toList();
        emit(PendingClassesLoaded(classes));
      } catch (e) {
        emit(
          ClassError(
            'Không thể tải danh sách lớp đang chờ duyệt: ${e.toString()}',
          ),
        );
      }
    });

    // Xử lý sự kiện đăng ký lớp học
    on<JoinClassEvent>((event, emit) async {
      print('JoinClassEvent triggered for classId: ${event.classId}');
      emit(ClassJoining());
      try {
        final response = await _classRepository.joinClass(event.classId);

        // Show notification for successful class registration (Student)
        await NotificationService().showClassRegistrationSuccessNotification(
          className: response.data.className,
          subject: response.data.subject,
        );

        emit(ClassJoinSuccess(response));
      } catch (e) {
        emit(ClassJoinError('Không thể đăng ký lớp học: ${e.toString()}'));
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
