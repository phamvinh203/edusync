import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_state.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_event.dart';
import 'package:edusync/models/class_model.dart';
import '../widgets/join_class_dialog.dart';
import '../widgets/subject_card.dart';

class StudentSubjectView extends StatelessWidget {
  const StudentSubjectView({super.key});

  void _showJoinClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => const JoinClassDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisteredClassesBloc, RegisteredClassesState>(
      builder: (context, state) {
        // Lọc lấy các lớp type='regular'
        List<ClassModel> regularClasses = [];
        bool isLoading = state is RegisteredClassesLoading;

        if (state is RegisteredClassesLoaded) {
          regularClasses =
              state.registeredClasses
                  .where((c) => c.type.toLowerCase() == 'regular')
                  .toList();
        }

        final hasClasses = regularClasses.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RegisteredClassesBloc>().add(
              RefreshRegisteredClassesEvent(),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
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
                        // Text(
                        //   hasClasses
                        //       ? '${regularClasses.length} môn học đang tham gia'
                        //       : 'Chưa tham gia môn nào',
                        //   style: Theme.of(context).textTheme.bodyMedium
                        //       ?.copyWith(color: Colors.grey[600]),
                        // ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showJoinClassDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Nhập mã'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!hasClasses)
                _buildEmptyState(context)
              else
                _buildClassesList(
                  context,
                  regularClasses,
                ), // Truyền context vào hàm
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'Chưa có môn học nào',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Nhập mã lớp do giáo viên cung cấp để bắt đầu tham gia các môn học chính khóa',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _showJoinClassDialog(context),
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Nhập mã lớp học'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Cập nhật hàm để nhận context và wrap GridView với MediaQuery.removePadding
  Widget _buildClassesList(BuildContext context, List<ClassModel> classes) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true, // Loại bỏ padding top tự động từ MediaQuery
      // Có thể thêm removeBottom: true nếu cần loại bỏ padding bottom
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          return SubjectCard(classItem: classes[index], userRole: 'student');
        },
      ),
    );
  }
}
