import 'package:flutter/material.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/repositories/class_repository.dart';

class PendingStudentsScreen extends StatefulWidget {
  final String classId;
  final String className;
  final VoidCallback? onStudentApproved;

  const PendingStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
    this.onStudentApproved,
  });

  @override
  State<PendingStudentsScreen> createState() => _PendingStudentsScreenState();
}

class _PendingStudentsScreenState extends State<PendingStudentsScreen> {
  final ClassRepository _classRepository = ClassRepository();
  PendingStudentsResponse? _pendingStudents;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPendingStudents();
  }

  Future<void> _loadPendingStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _classRepository.getPendingStudents(
        widget.classId,
      );

      if (mounted) {
        setState(() {
          _pendingStudents = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveStudent(String studentId, String studentName) async {
    try {
      final response = await _classRepository.approveStudent(
        widget.classId,
        studentId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã duyệt học sinh ${response.approvedStudent.username}',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Gọi callback để thông báo đã có thay đổi
        widget.onStudentApproved?.call();

        // Reload danh sách sau khi duyệt
        _loadPendingStudents();

        // Nếu không còn học sinh chờ duyệt, quay lại màn hình trước
        if (response.data.totalPending == 0) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true); // Trả về true để báo có thay đổi
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showApproveConfirmation(UserProfile student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận duyệt'),
            content: Text(
              'Bạn có chắc chắn muốn duyệt học sinh "${student.username}" vào lớp học?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _approveStudent(student.id ?? '', student.username ?? '');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Duyệt'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Học sinh chờ duyệt',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              widget.className,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải danh sách học sinh chờ duyệt...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPendingStudents,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_pendingStudents == null || _pendingStudents!.data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có học sinh nào chờ duyệt',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tất cả học sinh đã được duyệt hoặc chưa có ai đăng ký',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPendingStudents,
      child: Column(
        children: [
          // Header thông tin
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_pendingStudents!.totalPending} học sinh chờ duyệt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                      Text(
                        'Nhấn vào nút "Duyệt" để xác nhận học sinh vào lớp',
                        style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Danh sách học sinh chờ duyệt
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingStudents!.data.length,
              itemBuilder: (context, index) {
                final student = _pendingStudents!.data[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar
                        student.avatar != null && student.avatar!.isNotEmpty
                            ? CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(student.avatar!),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Nếu không tải được ảnh, hiển thị avatar mặc định
                              },
                            )
                            : CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                student.username != null &&
                                        student.username!.isNotEmpty
                                    ? student.username![0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                        const SizedBox(width: 16),

                        // Thông tin học sinh
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.username ?? 'Không có tên',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                student.email ?? 'Không có email',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (student.userClass != null &&
                                  student.userClass!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Lớp: ${student.userClass}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Nút duyệt
                        Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed:
                                  () => _showApproveConfirmation(student),
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text(
                                'Duyệt',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Chờ duyệt',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
