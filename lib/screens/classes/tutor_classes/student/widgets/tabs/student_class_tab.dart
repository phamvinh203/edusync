import 'package:edusync/screens/classes/tutor_classes/student/widgets/bottom_sheets/available_classes_bottom_sheet.dart';
import 'package:edusync/screens/classes/tutor_classes/student/widgets/bottom_sheets/pending_classes_bottom_sheet.dart';
import 'package:edusync/screens/classes/tutor_classes/student/widgets/buttons/student_action_buttons_widget.dart';
import 'package:edusync/screens/classes/tutor_classes/student/widgets/lists/class_list_widget.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/mixins/class_tab_mixin.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/states/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/models/class_model.dart';

class StudentClassTab extends StatefulWidget {
  const StudentClassTab({super.key});

  @override
  State<StudentClassTab> createState() => _StudentClassTabState();
}

class _StudentClassTabState extends State<StudentClassTab>
    with AutomaticKeepAliveClientMixin, ClassTabMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  String get userRole => 'student';

  @override
  void initState() {
    super.initState();
    context.read<ClassBloc>().add(getLoadClassesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildClassTabContent(context);
  }

  @override
  ClassEvent getLoadClassesEvent() => GetRegisteredClassesEvent();

  @override
  ClassEvent getRefreshClassesEvent() => GetRegisteredClassesEvent();

  @override
  Widget buildClassList(BuildContext context, List<ClassModel> classes) {
    return ClassListWidget(classes: classes, userRole: userRole);
  }

  @override
  Widget? buildAdditionalWidgets(BuildContext context) {
    return StudentActionButtonsWidget(
      onFindClasses: () => _showAvailableClassesBottomSheet(context),
      onViewPending: () => _showPendingClassesBottomSheet(context),
    );
  }

  @override
  Widget buildEmptyState(BuildContext context) {
    return EmptyStateWidget(userRole: userRole);
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
