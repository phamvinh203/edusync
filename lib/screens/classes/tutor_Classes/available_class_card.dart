
import 'package:edusync/blocs/AvailableClasses/availableClasses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';

class AvailableClassCard extends StatelessWidget {
  final ClassModel classItem;
  final RegistrationStatus registrationStatus;
  final void Function(String classId) onRegister;

  const AvailableClassCard({
    super.key,
    required this.classItem,
    required this.registrationStatus,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final currentStudents = classItem.students.length;
    final maxStudents = classItem.maxStudents ?? 0;
    final isOpen = currentStudents < maxStudents;
    final subjectColor = _getSubjectColor(classItem.subject);

    // Lấy user id từ AuthBloc (giữ logic như cũ)
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';

    final isJoined =
        currentUserId.isNotEmpty && classItem.students.contains(currentUserId);
    final isPendingFromServer =
        currentUserId.isNotEmpty &&
        classItem.pendingStudents.contains(currentUserId);

    // Kết hợp server + bloc status
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

    String buttonLabel;
    IconData buttonIcon;
    if (isJoined || isRegisteredFromBloc) {
      buttonLabel = 'Đã tham gia lớp';
      buttonIcon = Icons.check_circle;
    } else if (isRegistering) {
      buttonLabel = 'Đang đăng ký...';
      buttonIcon = Icons.hourglass_top;
    } else if (isPending) {
      buttonLabel = 'Đang chờ giáo viên duyệt';
      buttonIcon = Icons.hourglass_empty;
    } else if (!isOpen) {
      buttonLabel = 'Lớp đã đầy';
      buttonIcon = Icons.block;
    } else {
      buttonLabel = 'Đăng ký tham gia';
      buttonIcon = Icons.app_registration;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header + details (giữ nguyên về mặt hiển thị)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.school, color: subjectColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classItem.nameClass,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Môn học: ${classItem.subject}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      'Lớp: ${classItem.gradeLevel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    if (classItem.teacherName?.isNotEmpty == true)
                      Text(
                        'Giáo viên: ${classItem.teacherName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (classItem.schedule.isNotEmpty)
                      Text(
                        'Lịch: ${_getScheduleText(classItem.schedule)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (classItem.location?.isNotEmpty == true)
                      Text(
                        'Địa chỉ: ${classItem.location}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (classItem.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        classItem.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Học sinh',
                  '$currentStudents/$maxStudents',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Giá/buổi',
                  classItem.pricePerSession != null
                      ? '${_formatCurrency(classItem.pricePerSession!)} VNĐ'
                      : 'Miễn phí',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Trạng thái',
                  isOpen ? 'Đang mở' : 'Đã đầy',
                  isOpen ? Colors.green : Colors.red,
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
      ),
    );
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

  String _getScheduleText(List<Schedule> schedule) {
    if (schedule.isEmpty) return '';
    if (schedule.length == 1) {
      final s = schedule.first;
      return '${s.dayOfWeek} ${s.startTime}-${s.endTime}';
    }
    return '${schedule.length} buổi/tuần';
  }

  String _formatCurrency(double amount) {
    if (amount == amount.toInt()) {
      return _addThousandsSeparator(amount.toInt().toString());
    } else {
      return _addThousandsSeparator(amount.toString());
    }
  }

  String _addThousandsSeparator(String number) {
    List<String> parts = number.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result += '.';
      }
      result += integerPart[i];
    }
    return result + decimalPart;
  }

  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'toán':
      case 'math':
        return Colors.blue;
      case 'vật lý':
      case 'physics':
        return Colors.purple;
      case 'hóa học':
      case 'chemistry':
        return Colors.green;
      case 'sinh học':
      case 'biology':
        return Colors.teal;
      case 'tiếng anh':
      case 'english':
        return Colors.orange;
      case 'văn học':
      case 'literature':
        return Colors.red;
      case 'lịch sử':
      case 'history':
        return Colors.brown;
      case 'địa lý':
      case 'geography':
        return Colors.cyan;
      default:
        return Colors.indigo;
    }
  }
}
