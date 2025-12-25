import 'package:edusync/screens/classes/tutor_classes/shared/widgets/states/error_state_widget.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/states/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/models/class_model.dart';

/// Mixin để chia sẻ logic chung giữa các tab classes
/// Giúp giảm code lặp lại trong teacher_class_tab và student_class_tab
mixin ClassTabMixin {
  /// Event để load classes (override trong widget)
  ClassEvent getLoadClassesEvent();

  /// Event để refresh classes (override trong widget)
  ClassEvent getRefreshClassesEvent();

  /// User role (teacher/student)
  String get userRole;

  /// Widget hiển thị danh sách classes
  Widget buildClassList(BuildContext context, List<ClassModel> classes);

  /// Widget hiển thị khi không có class nào
  Widget buildEmptyState(BuildContext context);

  /// Widget hiển thị thêm (ví dụ: action buttons cho student)
  Widget? buildAdditionalWidgets(BuildContext context) => null;

  /// Build UI với BlocBuilder (tái sử dụng logic)
  Widget buildClassTabContent(BuildContext context) {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const LoadingWidget();
        }
        if (state is ClassError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () {
              context.read<ClassBloc>().add(getLoadClassesEvent());
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
            context.read<ClassBloc>().add(getRefreshClassesEvent());
          },
          child: Column(
            children: [
              if (buildAdditionalWidgets(context) != null)
                buildAdditionalWidgets(context)!,
              Expanded(
                child:
                    classes.isEmpty
                        ? buildEmptyState(context)
                        : buildClassList(context, classes),
              ),
            ],
          ),
        );
      },
    );
  }
}
