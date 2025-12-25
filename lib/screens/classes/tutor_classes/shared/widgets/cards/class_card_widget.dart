import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/screens/classes/tutor_classes/widgets/base_class_card.dart';
import 'package:edusync/screens/classes/tutor_classes/teacher/screens/class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/l10n/app_localizations.dart';

class ClassCardWidget extends BaseClassCard {
  final String userRole;

  const ClassCardWidget({
    super.key,
    required super.classItem,
    required this.userRole,
  });

  @override
  Widget? buildTopRightWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppLocalizations.of(context)!.tutor,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget buildActionButtons(BuildContext context) {
    final subjectColor = getSubjectColorOverride();
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: mở màn hình bài tập
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: subjectColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.assignment_turned_in, size: 18),
            label: Text(AppLocalizations.of(context)!.exercises),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToDetail(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: subjectColor,
              side: BorderSide(color: subjectColor),
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.info_outline, size: 18),
            label: Text(AppLocalizations.of(context)!.detail),
          ),
        ),
      ],
    );
  }

  @override
  VoidCallback? onCardTap(BuildContext context) =>
      () => _navigateToDetail(context);

  Future<void> _navigateToDetail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ClassDetailScreen(
              classId: classItem.id ?? '',
              className: classItem.nameClass,
              userRole: userRole,
            ),
      ),
    );

    if (result == true && context.mounted) {
      if (userRole.toLowerCase() == 'student') {
        context.read<ClassBloc>().add(GetRegisteredClassesEvent());
      } else {
        context.read<ClassBloc>().add(RefreshClassesEvent());
      }
    }
  }
}
