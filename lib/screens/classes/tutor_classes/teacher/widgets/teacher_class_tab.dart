import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/mixins/class_tab_mixin.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/states/empty_state_widget.dart';
import 'package:edusync/screens/classes/tutor_classes/student/widgets/lists/class_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherClassTab extends StatefulWidget {
  const TeacherClassTab({super.key});

  @override
  State<TeacherClassTab> createState() => _TeacherClassTabState();
}

class _TeacherClassTabState extends State<TeacherClassTab>
    with AutomaticKeepAliveClientMixin, ClassTabMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  String get userRole => 'teacher';

  @override
  void initState() {
    super.initState();
    final currentState = context.read<ClassBloc>().state;
    if (currentState is! ClassLoaded && currentState is! ClassCreateSuccess) {
      context.read<ClassBloc>().add(getLoadClassesEvent());
    }
  }

  @override
  ClassEvent getLoadClassesEvent() => LoadClassesEvent();

  @override
  ClassEvent getRefreshClassesEvent() => RefreshClassesEvent();

  @override
  Widget buildClassList(BuildContext context, List<ClassModel> classes) {
    return ClassListWidget(classes: classes, userRole: userRole);
  }

  @override
  Widget buildEmptyState(BuildContext context) {
    return EmptyStateWidget(userRole: userRole);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildClassTabContent(context);
  }
}
