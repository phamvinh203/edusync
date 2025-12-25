import 'package:edusync/utils/class_info_helper.dart';
import 'package:edusync/utils/day_of_week.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

class RegisterClassDialog extends StatelessWidget {
  final ClassModel classItem;
  final Color subjectColor;
  final bool isRegistering;
  final bool isRegistered;
  final JoinClassData? registrationData;
  final VoidCallback onRegister;
  final VoidCallback? onCancel; // NEW

  const RegisterClassDialog({
    super.key,
    required this.classItem,
    required this.subjectColor,
    required this.isRegistering,
    required this.isRegistered,
    this.registrationData,
    required this.onRegister,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.registerTutorClass),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.confirmRegister(classItem.nameClass),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.classInfo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          if (classItem.teacherName != null)
            Text(
              '- ${AppLocalizations.of(context)!.teacherLabel}: ${classItem.teacherName}',
            ),
          Text('- ${AppLocalizations.of(context)!.scheduleLabel}'),
          if (classItem.schedule.isNotEmpty)
            ..._getScheduleDetails(context, classItem.schedule)
          else
            Text('  ${AppLocalizations.of(context)!.noScheduleYet}'),
          if (classItem.pricePerSession != null)
            Text(
              '- ${AppLocalizations.of(context)!.tuitionFee}: ${ClassInfoHelper.formatCurrency(classItem.pricePerSession!)} ${AppLocalizations.of(context)!.perSession}',
            ),
          if (classItem.location != null)
            Text(
              '- ${AppLocalizations.of(context)!.addressLabel}: ${classItem.location}',
            ),
          if (classItem.description != null &&
              classItem.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.descriptionLabel}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              classItem.description!,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
<<<<<<< HEAD:lib/screens/classes/tutor_Classes/student/widgets/show_register_dialog.dart

          // Hiển thị trạng thái đã đăng ký (nếu parent đã báo)
          if (isRegistered) _buildRegisteredStatus(),
=======
          if (isRegistered) _buildRegisteredStatus(context),
>>>>>>> 73aecbacdb1ec8be33a24a60c40dbfb4fb115cfd:lib/screens/classes/tutor_classes/student/widgets/dialogs/show_register_dialog.dart
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // gọi onCancel trước khi đóng dialog (để revert trạng thái trong Bloc)
            if (onCancel != null) onCancel!();
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        if (!isRegistered)
          ElevatedButton.icon(
            onPressed:
                isRegistering
                    ? null
                    : () {
<<<<<<< HEAD:lib/screens/classes/tutor_Classes/student/widgets/show_register_dialog.dart
                      // Gọi callback để parent gửi event lên Bloc.
                      // KHÔNG pop dialog ở đây -> để BlocListener xử lý pop khi success/error.
=======
>>>>>>> 73aecbacdb1ec8be33a24a60c40dbfb4fb115cfd:lib/screens/classes/tutor_classes/student/widgets/dialogs/show_register_dialog.dart
                      onRegister();
                    },
            icon:
                isRegistering
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.person_add),
            label: Text(
              isRegistering
                  ? AppLocalizations.of(context)!.registering
                  : AppLocalizations.of(context)!.register,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: subjectColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  List<Widget> _getScheduleDetails(
    BuildContext context,
    List<Schedule> schedule,
  ) {
    return schedule
        .map(
          (s) => Text(
            '  + ${getVietnameseDayOfWeek(s.dayOfWeek)} ${s.startTime}-${s.endTime}',
          ),
        )
        .toList();
  }

  Widget _buildRegisteredStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.alreadyRegistered,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
