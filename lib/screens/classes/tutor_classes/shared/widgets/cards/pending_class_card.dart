import 'package:edusync/utils/style_icon.dart';
import 'package:flutter/material.dart';

import 'package:edusync/screens/classes/tutor_classes/widgets/base_class_card.dart';

class PendingClassCard extends BaseClassCard {
  const PendingClassCard({super.key, required super.classItem});

  @override
  Color getSubjectColorOverride() => getSubjectColor(classItem.subject);

  @override
  IconData getSubjectIconOverride() => getSubjectIcon(classItem.subject);

  @override
  Color? getBorderColor() => getSubjectColorOverride().withValues(alpha: 0.3);

  @override
  List<BoxShadow>? getBoxShadow() => [
    BoxShadow(
      color: getSubjectColorOverride().withValues(alpha: 0.1),
      spreadRadius: 1,
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  Widget buildActionButtons(BuildContext context) {
    final subjectColor = getSubjectColorOverride();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: subjectColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: subjectColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_empty, size: 18, color: subjectColor),
          const SizedBox(width: 8),
          Text(
            'Đang chờ giáo viên duyệt',
            style: TextStyle(fontWeight: FontWeight.bold, color: subjectColor),
          ),
        ],
      ),
    );
  }

  @override
  bool get showBackgroundIcon => false;
}
