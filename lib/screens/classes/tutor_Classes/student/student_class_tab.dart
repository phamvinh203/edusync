import 'package:edusync/screens/classes/tutor_Classes/student/widgets/AvailableClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/PendingClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/StudentActionButtonsWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/ClassListWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/EmptyStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/ErrorStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/LoadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_bloc.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_state.dart';
import 'package:edusync/blocs/available_classes/available_classes_bloc.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_event.dart';
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
    context.read<RegisteredClassesBloc>().add(LoadRegisteredClassesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<RegisteredClassesBloc, RegisteredClassesState>(
      builder: (context, state) {
        if (state is RegisteredClassesLoading) {
          return const LoadingWidget();
        }
        if (state is RegisteredClassesError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () {
              context.read<RegisteredClassesBloc>().add(
                LoadRegisteredClassesEvent(),
              );
            },
          );
        }

        List<ClassModel> classes = [];
        if (state is RegisteredClassesLoaded) {
          classes = state.registeredClasses;
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RegisteredClassesBloc>().add(
              RefreshRegisteredClassesEvent(),
            );
          },
          child: Column(
            children: [
              StudentActionButtonsWidget(
                onFindClasses:
                    () => _showAvailableClassesBottomSheet(context, classes),
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

  void _showAvailableClassesBottomSheet(
    BuildContext context,
    List<ClassModel> classes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<AvailableClassesBloc>(),
          child: AvailableClassesBottomSheet(classes: classes),
        );
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
