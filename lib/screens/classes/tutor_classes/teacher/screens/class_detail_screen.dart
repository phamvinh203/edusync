import 'package:edusync/screens/classes/tutor_classes/teacher/screens/pending_students_screen.dart';
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/cards/class_header_card.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/sections/class_schedule_section.dart';
import 'package:edusync/screens/classes/tutor_classes/shared/widgets/sections/students_list_widget.dart';
import 'package:edusync/screens/exercises/exercises_tab.dart';
import 'package:edusync/screens/classes/tutor_classes/teacher/widgets/attendance_widget.dart';
import 'package:edusync/l10n/app_localizations.dart';

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

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  final ClassRepository _classRepository = ClassRepository();
  ClassModel? _classDetails;
  ClassStudentsResponse? _classStudents;
  bool _isLoading = true;
  bool _isLoadingStudents = false;
  String? _error;

  TabController? _tabController;

  // Ensure we always have a controller even after hot reload/state restore
  TabController get _ensureTabController {
    final tabsCount = _tabsLength;
    if (_tabController == null || _tabController!.length != tabsCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabsCount, vsync: this);
    }
    return _tabController!;
  }

  int get _tabsLength => widget.userRole?.toLowerCase() == 'teacher' ? 4 : 3;

  @override
  void initState() {
    super.initState();
    // Initialize once; also guarded by _ensureTabController for hot reload cases
    _tabController = TabController(length: _tabsLength, vsync: this);
    _loadClassDetails();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
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
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStudents = false);

        if (widget.userRole?.toLowerCase() == 'student' &&
            e.toString().contains('403')) {
          return; // Silent fail
        }
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_classDetails == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.classInfoNotFound),
      );
    }

    final isTeacher = widget.userRole?.toLowerCase() == 'teacher';

    return RefreshIndicator(
      onRefresh: _loadClassDetails,
      child: Column(
        children: [
          // Header + Thông tin lớp cố định
          ClassHeaderCard(
            classDetails: _classDetails!,
            classStudents: _classStudents,
            isTeacher: isTeacher,
          ),
          // Tab bar moved into body below the header
          Material(
            color: Colors.transparent,
            child: TabBar(
              controller: _ensureTabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodyMedium?.color,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.studentsLabel),
                Tab(text: AppLocalizations.of(context)!.exercises),
                Tab(text: AppLocalizations.of(context)!.classSchedule),
                if (isTeacher)
                  Tab(text: AppLocalizations.of(context)!.attendance),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _ensureTabController,
              children: [
                _buildStudentsSection(),
                ExercisesTab(
                  classId: widget.classId,
                  isTeacher: isTeacher,
                  role: widget.userRole ?? 'student',
                ),
                ClassScheduleSection(classDetails: _classDetails!),
                if (isTeacher)
                  AttendanceTab(
                    classId: widget.classId,
                    students: _classStudents?.students ?? const [],
                  ),
              ],
            ),
          ),
        ],
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
    return StudentsListWidget(
      classDetails: _classDetails!,
      classStudents: _classStudents,
      isLoadingStudents: _isLoadingStudents,
      isForStudent: widget.userRole?.toLowerCase() == 'student',
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
                  AppLocalizations.of(context)!.featureInDevelopment,
                  _showComingSoon,
                ),
                _buildMenuItem(
                  Icons.people_alt,
                  AppLocalizations.of(context)!.pendingStudentsTitle,
                  _goToPendingStudents,
                ),
                _buildMenuItem(
                  Icons.assignment,
                  AppLocalizations.of(context)!.exercises,
                  _showComingSoon,
                ),
                const Divider(),
                _buildMenuItem(
                  Icons.delete,
                  AppLocalizations.of(context)!.delete,
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
}
