import 'package:edusync/screens/classes/tutor_Classes/student/widgets/AvailableClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/PendingClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/StudentActionButtonsWidget.dart';
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

class StudentClassTab extends StatefulWidget {
  const StudentClassTab({super.key});

  @override
  State<StudentClassTab> createState() => _StudentClassTabState();
}

class _StudentClassTabState extends State<StudentClassTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ClassBloc>().add(GetRegisteredClassesEvent());
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
              context.read<ClassBloc>().add(GetRegisteredClassesEvent());
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
            context.read<ClassBloc>().add(GetRegisteredClassesEvent());
          },
          child: Column(
            children: [
              StudentActionButtonsWidget(
                onFindClasses: () => _showAvailableClassesBottomSheet(context),
                onViewPending: () => _showPendingClassesBottomSheet(context),
              ),
              Expanded(
                child:
                    classes.isEmpty
                        ? const EmptyStateWidget(userRole: 'student')
                        : ClassListWidget(
                          classes: classes,
                          userRole: 'student',
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAvailableClassesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return const AvailableClassesBottomSheet();
      },
    );
  }

  void _showPendingClassesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return const PendingClassesBottomSheet();
      },
    );
  }
}
