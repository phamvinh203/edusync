import 'package:edusync/utils/day_of_week.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

class ClassDetailSection extends StatelessWidget {
  final ClassModel classDetails;
  final ClassStudentsResponse? classStudents;

  const ClassDetailSection({
    super.key,
    required this.classDetails,
    this.classStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.classDetailInfo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (classDetails.description != null &&
                classDetails.description!.isNotEmpty) ...[
              _buildDetailRow(
                context,
                icon: Icons.description,
                label: AppLocalizations.of(context)!.descriptionLabel,
                value: classDetails.description!,
              ),
              const Divider(),
            ],

            _buildDetailRow(
              context,
              icon: Icons.school,
              label: AppLocalizations.of(context)!.subjectLabel,
              value: classDetails.subject,
            ),
            const Divider(),

            if (classDetails.location != null) ...[
              _buildDetailRow(
                context,
                icon: Icons.location_on,
                label: AppLocalizations.of(context)!.locationLabel,
                value: classDetails.location!,
              ),
              const Divider(),
            ],

            _buildDetailRow(
              context,
              icon: Icons.people,
              label: AppLocalizations.of(context)!.studentCountLabel,
              value: AppLocalizations.of(context)!.studentCountValue(
                classStudents?.students.length ?? classDetails.students.length,
                classDetails.maxStudents ?? 0,
              ),
            ),
            const Divider(),

            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: AppLocalizations.of(context)!.createdDate,
              value: formatDate(classDetails.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
