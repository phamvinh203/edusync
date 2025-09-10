import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'student/student_class_tab.dart';
import 'teacher/teacher_class_tab.dart';

class TutorClassTab extends StatelessWidget {
  const TutorClassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userRole = authState.user?.role ?? '';
        if (userRole.toLowerCase() == 'student') {
          return const StudentClassTab();
        } else {
          return const TeacherClassTab();
        }
      },
    );
  }
}