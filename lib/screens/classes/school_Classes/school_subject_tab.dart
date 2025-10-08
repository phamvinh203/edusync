import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'teacher/teacher_subject.dart';
import 'students/student_subject.dart';

class SchoolSubjectTab extends StatefulWidget {
  const SchoolSubjectTab({super.key});

  @override
  State<SchoolSubjectTab> createState() => _SchoolSubjectTabState();
}

class _SchoolSubjectTabState extends State<SchoolSubjectTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role.toLowerCase() ?? '';

    if (userRole == 'teacher') {
      return const TeacherSubjectView();
    } else {
      return const StudentSubjectView();
    }
  }
}
