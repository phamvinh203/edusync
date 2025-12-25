import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/utils/style_icon.dart';
import 'package:edusync/utils/day_of_week.dart';
import 'package:edusync/l10n/app_localizations.dart';

/// Base widget cung cấp layout chung cho các card lớp học.
/// Các lớp con có thể tuỳ chỉnh màu sắc, biểu tượng và phần hành động.
abstract class BaseClassCard extends StatelessWidget {
  final ClassModel classItem;

  const BaseClassCard({super.key, required this.classItem});

  /// Cho phép lớp con tuỳ chỉnh màu môn học.
  Color getSubjectColorOverride() => getSubjectColor(classItem.subject);

  /// Cho phép lớp con tuỳ chỉnh biểu tượng môn học.
  IconData getSubjectIconOverride() => getSubjectIcon(classItem.subject);

  /// Badge hoặc widget hiển thị góc trên bên phải.
  Widget? buildTopRightWidget(BuildContext context) => null;

  /// Phần thông tin bổ sung bên dưới địa chỉ.
  Widget? buildAdditionalInfo(BuildContext context) => null;

  /// Các nút hành động bắt buộc phải được cung cấp.
  Widget buildActionButtons(BuildContext context);

  /// Callback khi nhấn vào toàn bộ card.
  VoidCallback? onCardTap(BuildContext context) => null;

  /// Có hiển thị icon lớn ở nền hay không.
  bool get showBackgroundIcon => true;

  /// Màu viền card.
  Color? getBorderColor() => null;

  /// Shadow cho card.
  List<BoxShadow>? getBoxShadow() => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.08),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final subjectColor = getSubjectColorOverride();
    final subjectIcon = getSubjectIconOverride();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getBorderColor() ?? Colors.grey[200]!),
        boxShadow: getBoxShadow(),
      ),
      child: InkWell(
        onTap: onCardTap(context),
        child: Stack(
          children: [
            if (showBackgroundIcon)
              Positioned(
                right: 12,
                bottom: 12,
                child: Icon(
                  subjectIcon,
                  size: 80,
                  color: subjectColor.withValues(alpha: 0.08),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: subjectColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(subjectIcon, color: subjectColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classItem.nameClass,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildBasicInfo(context),
                        ],
                      ),
                    ),
                    if (buildTopRightWidget(context) != null) ...[
                      const SizedBox(width: 8),
                      buildTopRightWidget(context)!,
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                buildActionButtons(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    final theme = Theme.of(context).textTheme.bodySmall;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (classItem.subject.isNotEmpty)
          Text(
            '${l10n.subjectPrefix} ${classItem.subject}',
            style: theme?.copyWith(color: Colors.grey[600]),
          ),
        if (classItem.gradeLevel?.isNotEmpty == true)
          Text(
            '${l10n.gradePrefix} ${classItem.gradeLevel}',
            style: theme?.copyWith(color: Colors.grey[600]),
          ),
        if (classItem.teacherName?.isNotEmpty == true)
          Text(
            '${l10n.teacherPrefix} ${classItem.teacherName}',
            style: theme?.copyWith(color: Colors.grey[600]),
          ),
        if (classItem.schedule.isNotEmpty)
          Text(
            '${l10n.schedulePrefix} ${getScheduleText(classItem.schedule)}',
            style: theme?.copyWith(color: Colors.grey[600]),
          ),
        if (classItem.location?.isNotEmpty == true)
          Text(
            '${l10n.addressPrefix} ${classItem.location}',
            style: theme?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        if (buildAdditionalInfo(context) != null) ...[
          const SizedBox(height: 4),
          buildAdditionalInfo(context)!,
        ],
      ],
    );
  }
}
