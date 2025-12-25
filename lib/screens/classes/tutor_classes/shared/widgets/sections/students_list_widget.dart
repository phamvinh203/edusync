import 'package:edusync/utils/class_info_helper.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

class StudentsListWidget extends StatelessWidget {
  final ClassModel classDetails;
  final ClassStudentsResponse? classStudents;
  final bool isLoadingStudents;
  final bool isForStudent;

  const StudentsListWidget({
    super.key,
    required this.classDetails,
    this.classStudents,
    required this.isLoadingStudents,
    this.isForStudent = false,
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
            _buildHeader(context),
            const SizedBox(height: 16),
            // Khu vực danh sách cần có không gian cố định và cho phép cuộn
            Expanded(child: _buildStudentsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          isForStudent
              ? AppLocalizations.of(context)!.studentsInClass
              : AppLocalizations.of(context)!.studentsLabel,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isForStudent ? Colors.green[100] : Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _buildStudentCountText(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isForStudent ? Colors.green[700] : Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsList(BuildContext context) {
    if ((classStudents?.students.isEmpty ?? true) &&
        classDetails.students.isEmpty) {
      return _buildEmptyState(context);
    }

    if (isLoadingStudents) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (classStudents != null && classStudents!.students.isNotEmpty) {
      return _buildDetailedStudentsList();
    }

    return _buildBasicStudentsList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noStudentsYet,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStudentsList() {
    return ListView.builder(
      itemCount: classStudents!.students.length,
      itemBuilder: (context, index) {
        final student = classStudents!.students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildStudentAvatar(student),
            title: Text(
              student.username ?? 'Không có tên',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: _buildStudentSubtitle(student),
            trailing: _buildStudentTrailing(),
            onTap: isForStudent ? null : () => _onStudentTap(student),
          ),
        );
      },
    );
  }

  Widget _buildBasicStudentsList() {
    return ListView.builder(
      itemCount: classDetails.students.length,
      itemBuilder: (context, index) {
        final studentId = classDetails.students[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                isForStudent ? Colors.green[100] : Colors.blue[100],
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isForStudent ? Colors.green[700] : Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text('Học sinh ${index + 1}'),
          subtitle: Text('ID: $studentId'),
        );
      },
    );
  }

  Widget _buildStudentAvatar(UserProfile student) {
    if (student.avatar != null && student.avatar!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(student.avatar!),
        onBackgroundImageError: (exception, stackTrace) {},
      );
    }

    return CircleAvatar(
      backgroundColor: isForStudent ? Colors.green[100] : Colors.blue[100],
      child: Text(
        student.username != null && student.username!.isNotEmpty
            ? student.username![0].toUpperCase()
            : '?',
        style: TextStyle(
          color: isForStudent ? Colors.green[700] : Colors.blue[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentSubtitle(UserProfile student) {
    if (isForStudent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (student.email?.isNotEmpty == true)
            Text('Email: ${student.email}'),
          if (student.userClass?.isNotEmpty == true)
            Text('Lớp: ${student.userClass}'),
        ],
      );
    }

    return student.email != null && student.email!.isNotEmpty
        ? Text(student.email!)
        : Text('ID: ${student.id ?? ''}');
  }

  Widget _buildStudentTrailing() {
    if (isForStudent) {
      return Icon(Icons.person, color: Colors.green[400]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Học sinh',
        style: TextStyle(
          fontSize: 12,
          color: Colors.green[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _onStudentTap(UserProfile student) {
    // TODO: Xem thông tin chi tiết học sinh
  }

  String _buildStudentCountText() {
    final loadedCount = classStudents?.students.length;
    final defaultText = ClassInfoHelper.getStudentCountText(classDetails);
    if (loadedCount != null) {
      final maxStudents = classDetails.maxStudents ?? 0;
      return '$loadedCount/$maxStudents';
    }
    return defaultText;
  }
}
