import 'package:edusync/screens/classes/tutor_Classes/widgets/AvailableClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/ClassListWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/EmptyStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/ErrorStateWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/LoadingWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/PendingClassesBottomSheetWidget.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/StudentActionButtonsWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/class_model.dart';


class TutorClassTab extends StatefulWidget {
  const TutorClassTab({super.key});

  @override
  State<TutorClassTab> createState() => _TutorClassTabState();
}

class _TutorClassTabState extends State<TutorClassTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<ClassBloc>().state;
    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role ?? '';
    if (userRole.toLowerCase() == 'student') {
      context.read<ClassBloc>().add(GetRegisteredClassesEvent());
    } else {
      if (currentState is! ClassLoaded && currentState is! ClassCreateSuccess) {
        context.read<ClassBloc>().add(LoadClassesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userRole = authState.user?.role ?? '';
        return BlocBuilder<ClassBloc, ClassState>(
          builder: (context, state) {
            if (state is ClassLoading) {
              return const LoadingWidget();
            }
            if (state is ClassError) {
              return ErrorStateWidget(
                message: state.message,
                onRetry: () {
                  if (userRole.toLowerCase() == 'student') {
                    context.read<ClassBloc>().add(GetRegisteredClassesEvent());
                  } else {
                    context.read<ClassBloc>().add(LoadClassesEvent());
                  }
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
                if (userRole.toLowerCase() == 'student') {
                  context.read<ClassBloc>().add(GetRegisteredClassesEvent());
                } else {
                  context.read<ClassBloc>().add(RefreshClassesEvent());
                }
              },
              child: Column(
                children: [
                  if (userRole.toLowerCase() == 'student')
                    StudentActionButtonsWidget(
                      onFindClasses: () => _showAvailableClassesBottomSheet(context, classes),
                      onViewPending: () => _showPendingClassesBottomSheet(context),
                    ),
                  Expanded(
                    child: classes.isEmpty
                        ? EmptyStateWidget(userRole: userRole)
                        : ClassListWidget(classes: classes, userRole: userRole),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị bottom sheet (giữ nguyên nhưng sẽ gọi widget riêng)
  void _showAvailableClassesBottomSheet(BuildContext context, List<ClassModel> classes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return AvailableClassesBottomSheet(classes: classes);
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