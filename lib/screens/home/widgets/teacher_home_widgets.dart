import 'package:flutter/material.dart';
import 'package:edusync/models/home_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

class TeacherStatsRow extends StatelessWidget {
  final TeacherClassStats classStats;

  const TeacherStatsRow({super.key, required this.classStats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.managedClasses,
              value: classStats.totalClasses.toString(),
              icon: Icons.class_,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.students,
              value: classStats.totalStudents.toString(),
              icon: Icons.people,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherPendingGradingRow extends StatelessWidget {
  final PendingGradingStats gradingStats;
  final TodaySchedule todaySchedule;

  const TeacherPendingGradingRow({
    super.key,
    required this.gradingStats,
    required this.todaySchedule,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.pendingGrading,
              value: gradingStats.totalPendingGrading.toString(),
              icon: Icons.grade,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: AppLocalizations.of(context)!.todayClasses,
              value: todaySchedule.totalClassesToday.toString(),
              icon: Icons.today,
              color: Colors.purple,
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

class QuickActionsSection extends StatelessWidget {
  final VoidCallback? onCreateExercise;
  final VoidCallback? onTakeAttendance;

  const QuickActionsSection({
    super.key,
    this.onCreateExercise,
    this.onTakeAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            AppLocalizations.of(context)!.quickActions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  title: AppLocalizations.of(context)!.createExercise,
                  icon: Icons.add_task,
                  color: Colors.blue,
                  onTap: onCreateExercise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  title: AppLocalizations.of(context)!.takeAttendance,
                  icon: Icons.how_to_reg,
                  color: Colors.green,
                  onTap: onTakeAttendance,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TodayScheduleWidget extends StatelessWidget {
  final TodaySchedule todaySchedule;

  const TodayScheduleWidget({super.key, required this.todaySchedule});

  @override
  Widget build(BuildContext context) {
    if (todaySchedule.classes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.today, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.todaySchedule(todaySchedule.totalClassesToday),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[800],
                  ),
                ),
              ],
            ),
          ),
          ...todaySchedule.classes.map(
            (todayClass) => TodayClassItem(todayClass: todayClass),
          ),
        ],
      ),
    );
  }
}

class TodayClassItem extends StatelessWidget {
  final TodayClass todayClass;

  const TodayClassItem({super.key, required this.todayClass});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  todayClass.className,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todayClass.subject,
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                todayClass.timeRange,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              if (todayClass.location != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  todayClass.location!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(
                  context,
                )!.studentCount(todayClass.studentCount),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TeacherRecentActivitiesSection extends StatelessWidget {
  final List<RecentActivity> activities;

  const TeacherRecentActivitiesSection({super.key, required this.activities});

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
              return TeacherRecentActivityItem(activity: activity);
            },
          ),
      ],
    );
  }
}

class TeacherRecentActivityItem extends StatelessWidget {
  final RecentActivity activity;

  const TeacherRecentActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // compute localized title/description when metadata present
    final loc = AppLocalizations.of(context);
    String title = activity.title;
    String description = activity.description;
    if (loc != null) {
      switch (activity.type) {
        case 'submission':
          title = loc.submission;
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
        trailing: _getActionButton(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _getActivityIcon() {
    IconData iconData;
    Color iconColor;

    switch (activity.type) {
      case 'exercise_created':
        iconData = Icons.add_circle;
        iconColor = Colors.blue;
        break;
      case 'class_schedule':
        iconData = Icons.schedule;
        iconColor = Colors.purple;
        break;
      case 'submission':
        iconData = Icons.assignment_turned_in;
        iconColor = Colors.green;
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

  Widget? _getActionButton(BuildContext context) {
    if (activity.type == 'exercise_created') {
      final submissionCount = activity.metadata?['submissionCount'] ?? 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context)!.submissionCount(submissionCount),
          style: TextStyle(
            color: Colors.orange[700],
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return null;
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
