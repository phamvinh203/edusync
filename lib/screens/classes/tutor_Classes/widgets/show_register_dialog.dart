import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';

class ShowRegisterDialog extends StatelessWidget {
  final ClassModel classItem;
  final Color subjectColor;
  final bool isRegistering;
  final bool isRegistered;
  final Object? registrationData; // optional: reserved for future display
  final VoidCallback onRegister;

  const ShowRegisterDialog({
    super.key,
    required this.classItem,
    required this.subjectColor,
    required this.isRegistering,
    required this.isRegistered,
    required this.onRegister,
    this.registrationData,
  });

  // Static method để gọi từ UI (bottom sheet/tab)
  static void show(
    BuildContext context,
    ClassModel classItem,
    Color subjectColor,
  ) {
    final bloc = context.read<ClassBloc>();
    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role ?? '';

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocListener<ClassBloc, ClassState>(
            bloc: bloc,
            listener: (listenerContext, state) {
              if (state is ClassJoinSuccess && state.success) {
                // Đóng dialog sau success
                Navigator.pop(dialogContext);
                // BLoC đã refresh trong handler, nhưng thêm snackbar
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đăng ký thành công! Trạng thái: ${state.response.data.status}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (state is ClassJoinError) {
                Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: BlocBuilder<ClassBloc, ClassState>(
              bloc: bloc,
              builder: (context, state) {
                final isRegistering = state is ClassJoining;
                final isRegistered = state is ClassJoinSuccess && state.success;

                return ShowRegisterDialog(
                  classItem: classItem,
                  subjectColor: subjectColor,
                  isRegistering: isRegistering,
                  isRegistered: isRegistered,
                  // SỬA: Thêm registrationData nếu cần hiển thị status/position
                  registrationData:
                      state is ClassJoinSuccess && state.success
                          ? state.response.data
                          : null,
                  onRegister: () {
                    // Dispatch với userRole
                    bloc.add(
                      JoinClassEvent(classItem.id ?? '', userRole: userRole),
                    );
                  },
                );
              },
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đăng ký lớp gia sư'),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn có muốn đăng ký vào lớp "${classItem.nameClass}"?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Text(
            'Thông tin lớp:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),

          if (classItem.teacherName != null)
            Text('- Giáo viên: ${classItem.teacherName}'),

          Text(
            '- Lịch học:',
            // style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (classItem.schedule.isNotEmpty)
            ..._getScheduleDetails(classItem.schedule),
          if (classItem.pricePerSession != null)
            Text(
              '- Học phí: ${_formatCurrency(classItem.pricePerSession!)} VNĐ/buổi',
            ),
          if (classItem.location != null)
            Text('- Địa chỉ: ${classItem.location}'),
          if (classItem.description != null &&
              classItem.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Mô tả:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              classItem.description!,
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          // Hiển thị trạng thái đã đăng ký
          if (isRegistered) _buildRegisteredStatus(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        if (!isRegistered)
          ElevatedButton.icon(
            onPressed:
                isRegistering
                    ? null
                    : () {
                      Navigator.pop(context);
                      onRegister(); // gọi callback thực hiện đăng ký
                    },
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
            label: Text(isRegistering ? 'Đang đăng ký...' : 'Đăng ký'),
            style: ElevatedButton.styleFrom(
              backgroundColor: subjectColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  // helper functions
  List<Widget> _getScheduleDetails(List<Schedule> schedule) {
    if (schedule.isEmpty) return [const Text('Chưa có lịch học')];

    return schedule.map((s) {
      return Text('  + ${s.dayOfWeek} ${s.startTime}-${s.endTime}');
    }).toList();
  }

  // helper: hiển thị trạng thái đã đăng ký
  Widget _buildRegisteredStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn đã đăng ký lớp này',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCurrency(num value) {
    return value.toStringAsFixed(0);
  }
}
