import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/screens/classes/tutor_Classes/pending_students_screen.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/class_header_card.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/class_detail_section.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/class_schedule_section.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/students_list_widget.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String? userRole;

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
  

  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

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

        _checkStudentApprovalStatus();
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
      setState(() => _isLoadingStudents = true);

      final response = await _classRepository.getClassStudents(widget.classId);

      if (mounted) {
        setState(() {
          _classStudents = response;
          _isLoadingStudents = false;
        });

        if (widget.userRole?.toLowerCase() == 'student') {
          _markStudentAsApproved();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStudents = false);

        if (widget.userRole?.toLowerCase() == 'student' &&
            e.toString().contains('403')) {
          return; // Silent fail cho student chưa được approve
        }

        print('Lỗi tải danh sách học sinh: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        widget.className,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      elevation: 0,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      actions: [
        if (widget.userRole?.toLowerCase() == 'teacher')
          IconButton(
            onPressed: _showMenuOptions,
            icon: const Icon(Icons.more_vert),
          ),
      ],
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
      return _buildErrorWidget();
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
            ClassHeaderCard(
              classDetails: _classDetails!,
              classStudents: _classStudents,
            ),
            ClassDetailSection(
              classDetails: _classDetails!,
              classStudents: _classStudents,
            ),
            ClassScheduleSection(classDetails: _classDetails!),
            _buildStudentsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
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

  Widget _buildStudentsSection() {
    if (widget.userRole?.toLowerCase() == 'student') {
      if (_isRegistered && _classStudents != null) {
        return StudentsListWidget(
          classDetails: _classDetails!,
          classStudents: _classStudents,
          isLoadingStudents: _isLoadingStudents,
          isForStudent: true,
        );
      }
      // return RegistrationSection(
      //   classDetails: _classDetails!,
      //   isRegistered: _isRegistered,
      //   isRegistering: _isRegistering,
      //   registrationData: _registrationData,
      //   onRegister: _showRegistrationDialog,
      // );
    }

    return StudentsListWidget(
      classDetails: _classDetails!,
      classStudents: _classStudents,
      isLoadingStudents: _isLoadingStudents,
    );
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
                _buildMenuItem(
                  Icons.edit,
                  'Chỉnh sửa lớp học',
                  _showComingSoon,
                ),
                _buildMenuItem(
                  Icons.people_alt,
                  'Học sinh chờ duyệt',
                  _goToPendingStudents,
                ),
                _buildMenuItem(
                  Icons.assignment,
                  'Bài tập và điểm số',
                  _showComingSoon,
                ),
                const Divider(),
                _buildMenuItem(
                  Icons.delete,
                  'Xóa lớp học',
                  _showDeleteConfirmation,
                  isDestructive: true,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : null),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tính năng đang phát triển')));
  }

  void _goToPendingStudents() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PendingStudentsScreen(
              classId: widget.classId,
              className: widget.className,
              onStudentApproved: refreshClassData,
            ),
      ),
    );

    if (result == true) refreshClassData();
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

  Future<void> _deleteClass() async {
    try {
      final response = await _classRepository.deleteClass(widget.classId);

      if (mounted) Navigator.pop(context); // Đóng loading

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
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Đóng loading

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

  
  void _markStudentAsApproved() {
    setState(() => _isRegistered = true);
  }

  void _checkStudentApprovalStatus() {
    if (widget.userRole?.toLowerCase() != 'student' || _classDetails == null)
      return;

    final authBloc = context.read<AuthBloc>();
    final currentUserId = authBloc.state.user?.id;

    if (currentUserId == null) return;

    bool isApproved = _classDetails!.students.contains(currentUserId);
    bool isPending = _classDetails!.pendingStudents.contains(currentUserId);

    if (isApproved) {
      setState(() {
        _isRegistered = true;
        
      });
    } else if (isPending) {
      setState(() {
        _isRegistered = true;
        
      });
    }
  }
}
