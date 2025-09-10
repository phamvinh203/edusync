// Widget hiển thị danh sách các lớp học.

import 'package:edusync/screens/classes/tutor_Classes/widgets/ClassCardWidget.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';

class ClassListWidget extends StatelessWidget {
  final List<ClassModel> classes;
  final String userRole;

  const ClassListWidget({
    super.key,
    required this.classes,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return ClassCardWidget(classItem: classItem, userRole: userRole);
      },
    );
  }
}