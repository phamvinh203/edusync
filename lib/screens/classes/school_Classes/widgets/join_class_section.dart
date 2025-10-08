import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import '../widgets/join_class_form.dart';

class JoinClassSection extends StatelessWidget {
  const JoinClassSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tham gia lớp học trường bằng mã',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập mã lớp do nhà trường hoặc giáo viên chủ nhiệm cung cấp để tham gia.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        // Use the shared JoinClassForm. When success, additionally notify ClassBloc
        JoinClassForm(
          onSuccess: () {
            try {
              context.read<ClassBloc>().add(LoadRegisteredClassesCountEvent());
            } catch (_) {
              // ignore if ClassBloc isn't available
            }
          },
        ),
      ],
    );
  }
}
