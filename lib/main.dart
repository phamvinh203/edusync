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
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
