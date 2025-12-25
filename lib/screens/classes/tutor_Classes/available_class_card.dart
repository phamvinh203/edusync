import 'package:edusync/models/class_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';

class AvailableClassCard extends StatefulWidget {
  final ClassModel classItem;
  final void Function(ClassModel, Color) onRegister;

  const AvailableClassCard({
    super.key,
    required this.classItem,
    required this.onRegister,
  });

  @override
  State<AvailableClassCard> createState() => _AvailableClassCardState();
}

class _AvailableClassCardState extends State<AvailableClassCard> {
  @override
  Widget build(BuildContext context) {
    final currentStudents = widget.classItem.students.length;
    final maxStudents = widget.classItem.maxStudents ?? 0;
    final isOpen = currentStudents < maxStudents;
    final subjectColor = _getSubjectColor(widget.classItem.subject);

    // Lấy thông tin user hiện tại để xác định trạng thái tham gia
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id ?? '';
    final isJoined =
        currentUserId.isNotEmpty &&
        widget.classItem.students.contains(currentUserId);
    final isPending =
        currentUserId.isNotEmpty &&
        widget.classItem.pendingStudents.contains(currentUserId);
    final canRegister = isOpen && !isJoined && !isPending;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.1),
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
                      widget.classItem.nameClass,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Môn học: ${widget.classItem.subject}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      'Lớp: ${widget.classItem.gradeLevel}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    if (widget.classItem.teacherName != null &&
                        widget.classItem.teacherName!.isNotEmpty)
                      Text(
                        'Giáo viên: ${widget.classItem.teacherName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (widget.classItem.schedule.isNotEmpty)
                      Text(
                        'Lịch: ${_getScheduleText(widget.classItem.schedule)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    if (widget.classItem.location != null &&
                        widget.classItem.location!.isNotEmpty)
                      Text(
                        'Địa chỉ: ${widget.classItem.location}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (widget.classItem.description != null &&
                        widget.classItem.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.classItem.description!,
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

          // Class info
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
                  widget.classItem.pricePerSession != null
                      ? '${_formatCurrency(widget.classItem.pricePerSession!)} VNĐ'
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

          // Register button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  canRegister
                      ? () {
                        widget.onRegister(widget.classItem, subjectColor);
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canRegister ? subjectColor : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: Icon(
                isJoined
                    ? Icons.check_circle
                    : isPending
                    ? Icons.hourglass_top
                    : isOpen
                    ? Icons.app_registration
                    : Icons.block,
                size: 18,
              ),
              label: Text(
                isJoined
                    ? 'Đã tham gia lớp'
                    : isPending
                    ? 'Đang chờ giáo viên duyệt'
                    : isOpen
                    ? 'Đăng ký tham gia'
                    : 'Lớp đã đầy',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

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

  // Hàm lấy màu theo môn học
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

  String _getScheduleText(List<Schedule> schedule) {
    if (schedule.isEmpty) return '';

    if (schedule.length == 1) {
      final s = schedule.first;
      return '${s.dayOfWeek} ${s.startTime}-${s.endTime}';
    }

    return '${schedule.length} buổi/tuần';
  }

  // Hàm format số tiền với dấu phẩy phân cách hàng nghìn
  String _formatCurrency(double amount) {
    if (amount == amount.toInt()) {
      // Nếu là số nguyên, hiển thị không có phần thập phân
      return _addThousandsSeparator(amount.toInt().toString());
    } else {
      // Nếu có phần thập phân
      return _addThousandsSeparator(amount.toString());
    }
  }

  // Hàm thêm dấu phẩy phân cách hàng nghìn
  String _addThousandsSeparator(String number) {
    // Tách phần nguyên và phần thập phân
    List<String> parts = number.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Thêm dấu phẩy vào phần nguyên
    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result += '.';
      }
      result += integerPart[i];
    }

    return result + decimalPart;
  }
}
