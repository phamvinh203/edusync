import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_event.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_state.dart';
import '../../repositories/class_repository.dart';

class RegisteredClassesBloc
    extends Bloc<RegisteredClassesEvent, RegisteredClassesState> {
  final ClassRepository classRepository;

  RegisteredClassesBloc({required this.classRepository})
    : super(RegisteredClassesInitial()) {
    on<LoadRegisteredClassesEvent>(_onLoadRegisteredClasses);
    on<RefreshRegisteredClassesEvent>(_onRefreshRegisteredClasses);
    on<AddRegisteredClassEvent>(_onAddRegisteredClass);
  }

  Future<void> _onLoadRegisteredClasses(
    LoadRegisteredClassesEvent event,
    Emitter<RegisteredClassesState> emit,
  ) async {
    emit(RegisteredClassesLoading());
    try {
      final classes = await classRepository.getMyRegisteredClasses();
      emit(RegisteredClassesLoaded(classes));
    } catch (e) {
      emit(RegisteredClassesError(e.toString()));
    }
  }

  Future<void> _onRefreshRegisteredClasses(
    RefreshRegisteredClassesEvent event,
    Emitter<RegisteredClassesState> emit,
  ) async {
    try {
      final classes = await classRepository.getMyRegisteredClasses();
      emit(RegisteredClassesLoaded(classes));
    } catch (e) {
      emit(RegisteredClassesError(e.toString()));
    }
  }

  void _onAddRegisteredClass(
    AddRegisteredClassEvent event,
    Emitter<RegisteredClassesState> emit,
  ) {
    if (state is RegisteredClassesLoaded) {
      final current = (state as RegisteredClassesLoaded).registeredClasses;
      emit(RegisteredClassesLoaded([...current, event.newClass]));
    }
  }
}
