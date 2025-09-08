import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

class RegistrationSection extends StatelessWidget {
  final ClassModel classDetails;
  final bool isRegistered;
  final bool isRegistering;
  final JoinClassData? registrationData;
  final VoidCallback onRegister;

  const RegistrationSection({
    super.key,
    required this.classDetails,
    required this.isRegistered,
    required this.isRegistering,
    this.registrationData,
    required this.onRegister,
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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildClassInfo(),
            const SizedBox(height: 16),
            _buildActionButton(),
            const SizedBox(height: 8),
            if (!isRegistered) _buildNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Đăng ký lớp học',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${classDetails.students.length}/${classDetails.maxStudents ?? 0} học sinh',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin lớp học',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text('Môn học: ${classDetails.subject}'),
          if (classDetails.description?.isNotEmpty == true)
            Text('Mô tả: ${classDetails.description}'),
          if (classDetails.location?.isNotEmpty == true)
            Text('Địa điểm: ${classDetails.location}'),
          Text('Số học sinh tối đa: ${classDetails.maxStudents ?? 0}'),
          Text(
            'Còn lại: ${(classDetails.maxStudents ?? 0) - classDetails.students.length} chỗ',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: isRegistered ? _buildRegisteredStatus() : _buildRegisterButton(),
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton.icon(
      onPressed: isRegistering ? null : onRegister,
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
        isRegistering ? 'Đang đăng ký...' : 'Đăng ký tham gia lớp học',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRegisteredStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã đăng ký thành công!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trạng thái: ${_getStatusText(registrationData?.status ?? '')}',
                      style: TextStyle(color: Colors.green[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (registrationData != null) _buildRegistrationDetails(),
        ],
      ),
    );
  }

  Widget _buildRegistrationDetails() {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Đăng ký lúc: ${_formatDateTime(registrationData!.registeredAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.queue, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Vị trí trong hàng chờ: ${registrationData!.position}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Text(
      '* Yêu cầu đăng ký sẽ được gửi đến giáo viên để xét duyệt',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xét duyệt';
      case 'approved':
        return 'Đã được duyệt';
      case 'rejected':
        return 'Bị từ chối';
      default:
        return status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
