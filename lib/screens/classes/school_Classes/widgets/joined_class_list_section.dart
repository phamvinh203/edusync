import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_state.dart';
import 'info_chip.dart';

class JoinedClassListSection extends StatelessWidget {
  const JoinedClassListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<RegisteredClassesBloc, RegisteredClassesState>(
      builder: (context, state) {
        if (state is RegisteredClassesLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RegisteredClassesLoaded) {
          // Lọc chỉ lấy lớp học trường (type='regular')
          final classes =
              state.registeredClasses
                  .where((c) => c.type.toLowerCase() == 'regular')
                  .toList();

          if (classes.isEmpty) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Bạn chưa tham gia lớp học trường nào bằng mã. Hãy nhập mã lớp để bắt đầu.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danh sách lớp học trường đã tham gia',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final cls = classes[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cls.nameClass,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              InfoChip(
                                icon: Icons.book,
                                label: 'Môn học',
                                value: cls.subject,
                              ),
                              InfoChip(
                                icon: Icons.confirmation_number,
                                label: 'Mã lớp',
                                value: cls.classCode ?? 'Chưa có',
                              ),
                              InfoChip(
                                icon: Icons.person,
                                label: 'Giáo viên',
                                value: cls.teacherName ?? 'Chưa cập nhật',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        } else if (state is RegisteredClassesError) {
          return Text(
            'Lỗi: ${state.message}',
            style: TextStyle(color: theme.colorScheme.error),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
