import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import '../widgets/subject_card.dart';

class TeacherSubjectView extends StatefulWidget {
  const TeacherSubjectView({super.key});

  @override
  State<TeacherSubjectView> createState() => _TeacherSubjectViewState();
}

class _TeacherSubjectViewState extends State<TeacherSubjectView> {
  bool _isLoading = false;
  List<ClassModel> _classes = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;
    final teacherId = user?.teacherId;

    if (teacherId == null || teacherId.isEmpty) {
      setState(() {
        _loadError = 'Không tìm thấy Teacher ID. Vui lòng đăng nhập lại.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final repository = context.read<ClassRepository>();
      final response = await repository.getMyCreatedClasses(teacherId);

      if (!mounted) return;

      // Lọc chỉ lấy lớp type='regular'
      final regularClasses =
          response.data
              .where((c) => c.type.toLowerCase() == 'regular')
              .toList();

      setState(() {
        _classes = regularClasses;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasClasses = _classes.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadClasses,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Môn học trường',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasClasses
                            ? '${_classes.length} lớp học đã tạo'
                            : 'Chưa có lớp học nào',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Content
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_loadError != null)
              _buildErrorState()
            else if (!hasClasses)
              _buildEmptyState()
            else
              _buildClassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải dữ liệu',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadClasses,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có lớp học nào',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Bạn chưa tạo lớp học chính khóa nào. Tạo lớp học mới để bắt đầu.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        return SubjectCard(classItem: _classes[index], userRole: 'teacher');
      },
    );
  }
}
