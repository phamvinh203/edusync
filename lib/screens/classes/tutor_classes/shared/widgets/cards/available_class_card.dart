import 'package:edusync/blocs/AvailableClasses/availableClasses_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/utils/class_info_helper.dart';
import 'package:edusync/utils/style_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:edusync/screens/classes/tutor_classes/widgets/base_class_card.dart';

class AvailableClassCard extends BaseClassCard {
  final RegistrationStatus registrationStatus;
  final void Function(String classId) onRegister;
  final Color? subjectColorOverrideValue;
  final IconData? subjectIconOverrideValue;

  const AvailableClassCard({
    super.key,
    required super.classItem,
    required this.registrationStatus,
    required this.onRegister,
    this.subjectColorOverrideValue,
    this.subjectIconOverrideValue,
  });

  @override
  Color getSubjectColorOverride() {
    return subjectColorOverrideValue ?? super.getSubjectColorOverride();
  }

  @override
  IconData getSubjectIconOverride() {
    return subjectIconOverrideValue ?? getSubjectIcon(classItem.subject);
  }

  @override
  Widget? buildAdditionalInfo(BuildContext context) {
    if (classItem.description?.isNotEmpty == true) {
      return Text(
        classItem.description!,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return null;
  }

  @override
  Widget buildActionButtons(BuildContext context) {
    final subjectColor = getSubjectColorOverride();

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    final isOpen = ClassInfoHelper.isClassOpen(classItem);
    final isJoined = ClassInfoHelper.isUserJoined(classItem, currentUserId);
    final isPendingFromServer = ClassInfoHelper.isUserPending(
      classItem,
      currentUserId,
    );

    final isRegistering = registrationStatus == RegistrationStatus.registering;
    final isRegisteredFromBloc =
        registrationStatus == RegistrationStatus.registered;
    final isPending =
        isPendingFromServer || registrationStatus == RegistrationStatus.pending;
    final canRegister =
        isOpen &&
        !isJoined &&
        !isPending &&
        !isRegisteredFromBloc &&
        registrationStatus == RegistrationStatus.idle;

    final (buttonLabel, buttonIcon) = _resolveButtonState(
      isJoined: isJoined || isRegisteredFromBloc,
      isRegistering: isRegistering,
      isPending: isPending,
      isOpen: isOpen,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Học sinh',
                ClassInfoHelper.getStudentCountText(classItem),
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Giá/buổi',
                ClassInfoHelper.getPriceText(classItem),
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatItem(
                'Trạng thái',
                ClassInfoHelper.getClassStatusText(classItem),
                ClassInfoHelper.isClassOpen(classItem)
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                canRegister ? () => onRegister(classItem.id ?? '') : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canRegister ? subjectColor : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(buttonIcon, size: 18),
            label: Text(
              buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  (String, IconData) _resolveButtonState({
    required bool isJoined,
    required bool isRegistering,
    required bool isPending,
    required bool isOpen,
  }) {
    if (isJoined) {
      return ('Đã tham gia lớp', Icons.check_circle);
    }
    if (isRegistering) {
      return ('Đang đăng ký...', Icons.hourglass_top);
    }
    if (isPending) {
      return ('Đang chờ giáo viên duyệt', Icons.hourglass_empty);
    }
    if (!isOpen) {
      return ('Lớp đã đầy', Icons.block);
    }
    return ('Đăng ký tham gia', Icons.app_registration);
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
