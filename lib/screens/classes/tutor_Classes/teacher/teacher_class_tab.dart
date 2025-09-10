import 'package:edusync/screens/classes/tutor_Classes/student/widgets/ClassListWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/EmptyStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/ErrorStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/LoadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/models/class_model.dart';


class TeacherClassTab extends StatefulWidget {
  const TeacherClassTab({super.key});

  @override
  State<TeacherClassTab> createState() => _TeacherClassTabState();
}

class _TeacherClassTabState extends State<TeacherClassTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<ClassBloc>().state;
    if (currentState is! ClassLoaded && currentState is! ClassCreateSuccess) {
      context.read<ClassBloc>().add(LoadClassesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const LoadingWidget();
        }
        if (state is ClassError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () {
              context.read<ClassBloc>().add(LoadClassesEvent());
            },
          );
        }

        List<ClassModel> classes = [];
        if (state is ClassLoaded) {
          classes = state.classes;
        } else if (state is ClassCreateSuccess) {
          classes = state.allClasses;
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ClassBloc>().add(RefreshClassesEvent());
          },
          child: classes.isEmpty
              ? const EmptyStateWidget(userRole: 'teacher')
              : ClassListWidget(classes: classes, userRole: 'teacher'),
        );
      },
    );
  }
}