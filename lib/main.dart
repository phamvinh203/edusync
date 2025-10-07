import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/repositories/auth_repository.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/repositories/user_repository.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/blocs/exercise/exercise_bloc.dart';
import 'package:edusync/repositories/exercise_repository.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_bloc.dart';
import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/core/services/notification_manager.dart';
import 'screens/auth/login_screen.dart';
import 'package:flutter/scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification services
  await NotificationService().init();
  await NotificationManager().init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes, check for new assignments for students
    if (state == AppLifecycleState.resumed) {
      NotificationManager().checkForNewAssignmentsForStudent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => ClassRepository()),
        RepositoryProvider(create: (_) => ExerciseRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(repository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    UserBloc(repository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create:
                (context) =>
                    ClassBloc(classRepository: context.read<ClassRepository>()),
          ),
          BlocProvider(
            create:
                (context) => ExerciseBloc(
                  repository: context.read<ExerciseRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => AvailableClassesBloc(
                  classRepository: context.read<ClassRepository>(),
                ),
          ),
          BlocProvider(
            create:
                (context) => RegisteredClassesBloc(
                  classRepository: context.read<ClassRepository>(),
                ),
          ),
        ],
        child: MaterialApp(
          title: 'EduSync',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[200]!),
            useMaterial3: true,
          ),
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
