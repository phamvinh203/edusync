import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/screens/classes/tutor_Classes/pending_students_screen.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String? userRole; // Thêm tham số userRole

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
    this.userRole,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final ClassRepository _classRepository = ClassRepository();
  ClassModel? _classDetails;
  ClassStudentsResponse? _classStudents;
  bool _isLoading = true;
  bool _isLoadingStudents = false;
  String? _error;

  // State cho đăng ký lớp học
  bool _isRegistered = false;
  bool _isRegistering = false;
  JoinClassData? _registrationData;

  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

  // Method để refresh data từ màn hình khác
  Future<void> refreshClassData() async {
    await _loadClassDetails();
  }

  Future<void> _loadClassDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await _classRepository.getClassDetails(widget.classId);

      if (mounted) {
        setState(() {
          _classDetails = response.data;
          _isLoading = false;
        });

        // Kiểm tra nếu user là student và đã được approve (có trong danh sách students)
        _checkStudentApprovalStatus();

        // Tải danh sách học sinh sau khi tải xong thông tin lớp
        _loadClassStudents();
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

  Future<void> _loadClassStudents() async {
    try {
      setState(() {
        _isLoadingStudents = true;
      });

      final response = await _classRepository.getClassStudents(widget.classId);

      if (mounted) {
        setState(() {
          _classStudents = response;
          _isLoadingStudents = false;
        });

        // Nếu là student và load được danh sách thành công
        // => student đã được approve
        if (widget.userRole?.toLowerCase() == 'student') {
          _markStudentAsApproved();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });

        // Nếu là student và gặp lỗi 403 (không có quyền), không cần báo lỗi
        // Vì đây là trường hợp bình thường khi student chưa được approve
        if (widget.userRole?.toLowerCase() == 'student' &&
            e.toString().contains('403')) {
          // Silent fail - student chưa được approve nên không xem được danh sách
          return;
        }

        // Không hiển thị lỗi cho việc tải học sinh, chỉ log
        print('Lỗi tải danh sách học sinh: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.className,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          // Chỉ hiển thị menu options cho teacher
          if (widget.userRole?.toLowerCase() == 'teacher')
            IconButton(
              onPressed: () {
                _showMenuOptions();
              },
              icon: const Icon(Icons.more_vert),
            ),
        ],
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
            Text('Đang tải thông tin lớp học...'),
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
              onPressed: _loadClassDetails,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_classDetails == null) {
      return const Center(child: Text('Không tìm thấy thông tin lớp học'));
    }

    return RefreshIndicator(
      onRefresh: _loadClassDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Header với thông tin cơ bản
            _buildHeaderCard(),

            // Thông tin chi tiết
            _buildDetailSection(),

            // Lịch học
            _buildScheduleSection(),

            // Danh sách học sinh
            _buildStudentsSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _classDetails!.nameClass,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _classDetails!.subject,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.people,
                text:
                    '${_classStudents?.students.length ?? _classDetails!.students.length}/${_classDetails!.maxStudents ?? 0}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                icon: Icons.schedule,
                text: '${_classDetails!.schedule.length} buổi/tuần',
              ),
              if (_classDetails!.location != null) ...[
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.location_on,
                  text: _classDetails!.location!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin chi tiết',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_classDetails!.description != null &&
                _classDetails!.description!.isNotEmpty) ...[
              _buildDetailRow(
                icon: Icons.description,
                label: 'Mô tả',
                value: _classDetails!.description!,
              ),
              const Divider(),
            ],

            _buildDetailRow(
              icon: Icons.school,
              label: 'Môn học',
              value: _classDetails!.subject,
            ),
            const Divider(),

            if (_classDetails!.location != null) ...[
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Địa điểm',
                value: _classDetails!.location!,
              ),
              const Divider(),
            ],

            _buildDetailRow(
              icon: Icons.people,
              label: 'Số lượng học sinh',
              value:
                  '${_classStudents?.students.length ?? _classDetails!.students.length}/${_classDetails!.maxStudents ?? 0} học sinh',
            ),
            const Divider(),

            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Ngày tạo',
              value: _formatDate(_classDetails!.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
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

  Widget _buildScheduleSection() {
    if (_classDetails!.schedule.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch học',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._classDetails!.schedule.map(
              (schedule) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getDayInVietnamese(schedule.dayOfWeek),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${schedule.startTime} - ${schedule.endTime}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsSection() {
    // Nếu role là student
    if (widget.userRole?.toLowerCase() == 'student') {
      // Nếu đã được duyệt (có thể load student list), hiển thị danh sách học sinh
      if (_isRegistered && _classStudents != null) {
        return _buildStudentsListForStudent();
      }
      // Ngược lại hiển thị phần đăng ký
      return _buildRegistrationSection();
    }

    // Hiển thị danh sách học sinh cho teacher/admin
    return _buildStudentsListForTeacher();
  }

  /// Hiển thị danh sách học sinh cho teacher/admin
  Widget _buildStudentsListForTeacher() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Học sinh',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_classStudents?.students.length ?? _classDetails!.students.length}/${_classDetails!.maxStudents ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if ((_classStudents?.students.isEmpty ?? true) &&
                _classDetails!.students.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có học sinh nào',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            else if (_isLoadingStudents)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_classStudents != null &&
                _classStudents!.students.isNotEmpty)
              // Hiển thị danh sách học sinh từ API với thông tin chi tiết
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classStudents!.students.length,
                itemBuilder: (context, index) {
                  final student = _classStudents!.students[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading:
                          student.avatar != null && student.avatar!.isNotEmpty
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(student.avatar!),
                                onBackgroundImageError: (
                                  exception,
                                  stackTrace,
                                ) {
                                  // Nếu không tải được ảnh, hiển thị avatar mặc định
                                },
                              )
                              : CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  student.username != null &&
                                          student.username!.isNotEmpty
                                      ? student.username![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      title: Text(
                        student.username ?? 'Không có tên',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle:
                          student.email != null && student.email!.isNotEmpty
                              ? Text(student.email!)
                              : Text('ID: ${student.id ?? ''}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                      ),
                      onTap: () {
                        // TODO: Xem thông tin chi tiết học sinh
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Xem thông tin ${student.username ?? 'học sinh'}',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            else
              // Hiển thị danh sách học sinh cơ bản nếu không có thông tin chi tiết
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classDetails!.students.length,
                itemBuilder: (context, index) {
                  final studentId = _classDetails!.students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Học sinh ${index + 1}'),
                    subtitle: Text('ID: $studentId'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị danh sách học sinh cho student đã được approve
  Widget _buildStudentsListForStudent() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Học sinh trong lớp',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_classStudents?.students.length ?? _classDetails!.students.length}/${_classDetails!.maxStudents ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Thông báo trạng thái
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bạn đã được duyệt vào lớp học này',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if ((_classStudents?.students.isEmpty ?? true) &&
                _classDetails!.students.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có học sinh nào khác',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            else if (_isLoadingStudents)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_classStudents != null &&
                _classStudents!.students.isNotEmpty)
              // Hiển thị danh sách học sinh từ API với thông tin chi tiết
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classStudents!.students.length,
                itemBuilder: (context, index) {
                  final student = _classStudents!.students[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading:
                          student.avatar != null && student.avatar!.isNotEmpty
                              ? CircleAvatar(
                                backgroundImage: NetworkImage(student.avatar!),
                                onBackgroundImageError: (
                                  exception,
                                  stackTrace,
                                ) {
                                  // Nếu không tải được ảnh, hiển thị avatar mặc định
                                },
                              )
                              : CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Text(
                                  student.username != null &&
                                          student.username!.isNotEmpty
                                      ? student.username![0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      title: Text(
                        student.username ?? 'Không có tên',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (student.email?.isNotEmpty == true)
                            Text('Email: ${student.email}'),
                          if (student.userClass?.isNotEmpty == true)
                            Text('Lớp: ${student.userClass}'),
                        ],
                      ),
                      trailing: Icon(Icons.person, color: Colors.green[400]),
                    ),
                  );
                },
              )
            else
              // Hiển thị danh sách học sinh từ class details (chỉ ID)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classDetails!.students.length,
                itemBuilder: (context, index) {
                  final studentId = _classDetails!.students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Học sinh ${index + 1}'),
                    subtitle: Text('ID: $studentId'),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getDayInVietnamese(String englishDay) {
    const dayMap = {
      'Monday': 'Thứ 2',
      'Tuesday': 'Thứ 3',
      'Wednesday': 'Thứ 4',
      'Thursday': 'Thứ 5',
      'Friday': 'Thứ 6',
      'Saturday': 'Thứ 7',
      'Sunday': 'Chủ nhật',
    };
    return dayMap[englishDay] ?? englishDay;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ';

    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMenuOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Chỉnh sửa lớp học'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to edit class screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang phát triển'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_alt),
                  title: const Text('Học sinh chờ duyệt'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PendingStudentsScreen(
                              classId: widget.classId,
                              className: widget.className,
                              onStudentApproved: () {
                                // Callback khi có học sinh được duyệt
                                refreshClassData();
                              },
                            ),
                      ),
                    );

                    // Nếu có thay đổi, refresh lại data
                    if (result == true) {
                      refreshClassData();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Bài tập và điểm số'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to assignments screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang phát triển'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Xóa lớp học',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa lớp học "${_classDetails!.nameClass}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteClass();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  /// Xóa lớp học
  Future<void> _deleteClass() async {
    try {
      // Hiển thị loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Gọi API xóa lớp học
      final response = await _classRepository.deleteClass(widget.classId);

      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo thành công với thông tin lớp học đã xóa
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${response.message}\nLớp: ${response.data.nameClass} - ${response.data.subject}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Quay lại màn hình trước với kết quả true để refresh danh sách
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (mounted) Navigator.pop(context);

      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa lớp học: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Widget hiển thị phần đăng ký lớp học cho student
  Widget _buildRegistrationSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Đăng ký lớp học',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_classDetails!.students.length}/${_classDetails!.maxStudents ?? 0} học sinh',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thông tin lớp học
            Container(
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
                  Text('Môn học: ${_classDetails!.subject}'),
                  if (_classDetails!.description?.isNotEmpty == true)
                    Text('Mô tả: ${_classDetails!.description}'),
                  if (_classDetails!.location?.isNotEmpty == true)
                    Text('Địa điểm: ${_classDetails!.location}'),
                  Text(
                    'Số học sinh tối đa: ${_classDetails!.maxStudents ?? 0}',
                  ),
                  Text(
                    'Còn lại: ${(_classDetails!.maxStudents ?? 0) - _classDetails!.students.length} chỗ',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Nút đăng ký hoặc trạng thái đã đăng ký
            SizedBox(
              width: double.infinity,
              child:
                  _isRegistered
                      ? _buildRegisteredStatus()
                      : ElevatedButton.icon(
                        onPressed:
                            _isRegistering
                                ? null
                                : () {
                                  _showRegistrationDialog();
                                },
                        icon:
                            _isRegistering
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.person_add),
                        label: Text(
                          _isRegistering
                              ? 'Đang đăng ký...'
                              : 'Đăng ký tham gia lớp học',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
            ),

            const SizedBox(height: 8),

            // Lưu ý
            if (!_isRegistered)
              Text(
                '* Yêu cầu đăng ký sẽ được gửi đến giáo viên để xét duyệt',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog xác nhận đăng ký
  void _showRegistrationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận đăng ký'),
            content: Text(
              'Bạn có muốn đăng ký tham gia lớp học "${_classDetails!.nameClass}"?\n\nYêu cầu sẽ được gửi đến giáo viên để xét duyệt.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _registerForClass();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đăng ký'),
              ),
            ],
          ),
    );
  }

  /// Xử lý đăng ký lớp học
  Future<void> _registerForClass() async {
    try {
      setState(() {
        _isRegistering = true;
      });

      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Gọi API đăng ký lớp học
      final response = await _classRepository.joinClass(widget.classId);

      // Đóng loading
      if (mounted) Navigator.pop(context);

      // Cập nhật state
      if (mounted) {
        setState(() {
          _isRegistered = true;
          _registrationData = response.data;
          _isRegistering = false;
        });

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Đóng loading
      if (mounted) Navigator.pop(context);

      // Cập nhật state
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });

        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đăng ký: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Widget hiển thị trạng thái đã đăng ký
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
                      'Trạng thái: ${_getStatusText(_registrationData?.status ?? '')}',
                      style: TextStyle(color: Colors.green[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_registrationData != null) ...[
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
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Đăng ký lúc: ${_formatDateTime(_registrationData!.registeredAt)}',
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
                        'Vị trí trong hàng chờ: ${_registrationData!.position}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Chuyển đổi status thành text tiếng Việt
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

  /// Đánh dấu student đã được approve (dựa vào việc có thể load được danh sách)
  void _markStudentAsApproved() {
    setState(() {
      _isRegistered = true;
      // Không cần tạo registrationData giả, chỉ cần đánh dấu _isRegistered = true
      // Logic approval sẽ dựa vào _classStudents != null
    });
  }

  /// Kiểm tra trạng thái approve của student
  void _checkStudentApprovalStatus() {
    // Chỉ check cho student
    if (widget.userRole?.toLowerCase() != 'student' || _classDetails == null) {
      return;
    }

    // Lấy user ID từ AuthBloc context
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.user?.id;

    if (currentUserId == null) return;

    // Kiểm tra user có trong danh sách students đã được approve
    bool isApproved = _classDetails!.students.contains(currentUserId);
    bool isPending = _classDetails!.pendingStudents.contains(currentUserId);

    if (isApproved) {
      setState(() {
        _isRegistered = true;
        // Tạo fake registration data cho trường hợp đã được approve
        _registrationData = JoinClassData(
          classId: widget.classId,
          className: widget.className,
          subject: _classDetails!.subject,
          teacherId: _classDetails!.teacherId ?? '',
          status: 'approved',
          registeredAt: DateTime.now(), // Không có thông tin chính xác
          position: 0, // Đã được duyệt nên không còn trong hàng chờ
        );
      });
    } else if (isPending) {
      setState(() {
        _isRegistered = true;
        // Tạo fake registration data cho trường hợp đang pending
        _registrationData = JoinClassData(
          classId: widget.classId,
          className: widget.className,
          subject: _classDetails!.subject,
          teacherId: _classDetails!.teacherId ?? '',
          status: 'pending',
          registeredAt: DateTime.now(), // Không có thông tin chính xác
          position: _classDetails!.pendingStudents.indexOf(currentUserId) + 1,
        );
      });
    }
  }

  /// Format DateTime thành string
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
