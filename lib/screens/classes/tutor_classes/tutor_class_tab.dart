import 'package:edusync/screens/classes/tutor_classes/student/widgets/tabs/student_class_tab.dart';
import 'package:edusync/screens/classes/tutor_classes/teacher/widgets/teacher_class_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';

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
