import 'package:flutter/material.dart';
import 'package:edusync/models/home_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

class StudentStatsRow extends StatelessWidget {
  final int todayAssignmentsCount;
  final int totalClassesJoined;

  const StudentStatsRow({
    super.key,
    required this.todayAssignmentsCount,
    required this.totalClassesJoined,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.todayAssignments,
              value: todayAssignmentsCount.toString(),
              icon: Icons.assignment,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.classesJoined,
              value: totalClassesJoined.toString(),
              icon: Icons.school,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivitiesSection extends StatelessWidget {
  final List<RecentActivity> activities;

  const RecentActivitiesSection({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.recentActivities,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (activities.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noActivities,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return RecentActivityItem(activity: activity);
            },
          ),
      ],
    );
  }
}

class RecentActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const RecentActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // compute localized title/description when metadata present
    final loc = AppLocalizations.of(context);
    String title = activity.title;
    String description = activity.description;
    if (loc != null) {
      switch (activity.type) {
        case 'submission':
          title =
              activity.metadata?['exerciseTitle'] != null
                  ? loc.submission
                  : activity.title;
          description =
              activity.metadata?['exerciseTitle'] != null
                  ? '${loc.submissionContent} "${activity.metadata!['exerciseTitle']}"${activity.metadata!['className'] != null ? ' - ${activity.metadata!['className']}' : ''}'
                  : activity.description;
          break;
        case 'class_schedule':
          title = loc.upcomingClassTitle;
          description =
              activity.metadata?['dayOfWeek'] != null &&
                      activity.metadata?['timeRange'] != null
                  ? '${activity.className} - ${activity.metadata!['dayOfWeek']} ${activity.metadata!['timeRange']}'
                  : activity.description;
          break;
        case 'assignment_due':
          title = loc.assignmentDueTitle;
          if (activity.metadata?['hoursUntilDue'] != null &&
              activity.metadata?['exerciseTitle'] != null) {
            description = loc.assignmentDueDescription(
              activity.metadata!['exerciseTitle'].toString(),
              activity.metadata!['hoursUntilDue'].toString(),
            );
          }
          break;
        case 'exercise_created':
          title = loc.newExerciseCreatedTitle;
          if (activity.metadata?['submissionCount'] != null &&
              activity.metadata?['exerciseTitle'] != null) {
            description = loc.newExerciseCreatedDescription(
              activity.metadata!['exerciseTitle'].toString(),
              activity.metadata!['submissionCount'].toString(),
            );
          }
          break;
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: _getActivityIcon(),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(context),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _getActivityIcon() {
    IconData iconData;
    Color iconColor;

    switch (activity.type) {
      case 'submission':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'class_schedule':
        iconData = Icons.schedule;
        iconColor = Colors.blue;
        break;
      case 'assignment_due':
        iconData = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'exercise_created':
        iconData = Icons.add_circle;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTimestamp(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(activity.timestamp);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else {
      return '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year}';
    }
  }
}

class TodayAssignmentsWidget extends StatelessWidget {
  final List<TodayAssignment> assignments;

  const TodayAssignmentsWidget({super.key, required this.assignments});

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.today, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.todayAssignmentsCount(assignments.length),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
          ...assignments.map(
            (assignment) => TodayAssignmentItem(assignment: assignment),
          ),
        ],
      ),
    );
  }
}

class TodayAssignmentItem extends StatelessWidget {
  final TodayAssignment assignment;

  const TodayAssignmentItem({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              assignment.isOverdue
                  ? Colors.red
                  : (assignment.isSubmitted ? Colors.green : Colors.orange),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              _getStatusChip(context),
            ],
          ),
          if (assignment.className != null) ...[
            const SizedBox(height: 4),
            Text(
              assignment.className!,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${AppLocalizations.of(context)!.deadline}: ${_formatDueDate()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getStatusChip(BuildContext context) {
    String text;
    Color backgroundColor;
    Color textColor;

    if (assignment.isSubmitted) {
      text = AppLocalizations.of(context)!.submitted;
      backgroundColor = Colors.green;
      textColor = Colors.white;
    } else if (assignment.isOverdue) {
      text = AppLocalizations.of(context)!.overdue;
      backgroundColor = Colors.red;
      textColor = Colors.white;
    } else {
      text = AppLocalizations.of(context)!.notSubmitted;
      backgroundColor = Colors.orange;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDueDate() {
    return '${assignment.dueDate.day}/${assignment.dueDate.month} ${assignment.dueDate.hour}:${assignment.dueDate.minute.toString().padLeft(2, '0')}';
  }
}
