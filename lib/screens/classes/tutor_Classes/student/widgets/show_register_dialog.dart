// import 'package:flutter/material.dart';
// import 'package:edusync/models/class_model.dart';
// import 'package:edusync/models/users_model.dart';
//
// class RegisterClassDialog extends StatelessWidget {
//   final ClassModel classItem;
//   final Color subjectColor;
//   final bool isRegistering;
//   final bool isRegistered;
//   final JoinClassData? registrationData;
//   final VoidCallback onRegister;
//
//   const RegisterClassDialog({
//     super.key,
//     required this.classItem,
//     required this.subjectColor,
//     required this.isRegistering,
//     required this.isRegistered,
//     this.registrationData,
//     required this.onRegister,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Đăng ký lớp gia sư'),
//
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Bạn có muốn đăng ký vào lớp "${classItem.nameClass}"?',
//             style: Theme.of(
//               context,
//             ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//
//           Text(
//             'Thông tin lớp:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           if (classItem.teacherName != null)
//             Text('- Giáo viên: ${classItem.teacherName}'),
//
//           Text(
//             '- Lịch học:',
//             // style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           if (classItem.schedule.isNotEmpty)
//             ..._getScheduleDetails(classItem.schedule),
//           if (classItem.pricePerSession != null)
//             Text(
//               '- Học phí: ${_formatCurrency(classItem.pricePerSession!)} VNĐ/buổi',
//             ),
//           if (classItem.location != null)
//             Text('- Địa chỉ: ${classItem.location}'),
//           if (classItem.description != null &&
//               classItem.description!.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               'Mô tả:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               classItem.description!,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//
//           // Hiển thị trạng thái đã đăng ký
//           if (isRegistered) _buildRegisteredStatus(),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Hủy'),
//         ),
//         if (!isRegistered)
//           ElevatedButton.icon(
//             onPressed:
//                 isRegistering
//                     ? null
//                     : () {
//                       // Không đóng Navigator.pop(context) ở đây, mà để callback đăng ký xử lý
//                       onRegister(); // gọi callback thực hiện đăng ký
//                     },
//             icon:
//                 isRegistering
//                     ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                     : const Icon(Icons.person_add),
//             label: Text(isRegistering ? 'Đang đăng ký...' : 'Đăng ký'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: subjectColor,
//               foregroundColor: Colors.white,
//             ),
//           ),
//       ],
//     );
//   }
//
//   // helper functions
//   List<Widget> _getScheduleDetails(List<Schedule> schedule) {
//     if (schedule.isEmpty) return [const Text('Chưa có lịch học')];
//
//     return schedule.map((s) {
//       return Text('  + ${s.dayOfWeek} ${s.startTime}-${s.endTime}');
//     }).toList();
//   }
//
//   // helper: hiển thị trạng thái đã đăng ký
//   Widget _buildRegisteredStatus() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.green[300]!),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle, color: Colors.green[600], size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'Bạn đã đăng ký lớp này',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green[700],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static String _formatCurrency(num value) {
//     return value.toStringAsFixed(0);
//   }
// }


// lib/screens/classes/tutor_Classes/student/show_register_dialog.dart
import 'package:flutter/material.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/models/users_model.dart';

class RegisterClassDialog extends StatelessWidget {
  final ClassModel classItem;
  final Color subjectColor;
  final bool isRegistering;
  final bool isRegistered;
  final JoinClassData? registrationData;
  final VoidCallback onRegister;
  final VoidCallback? onCancel; // NEW

  const RegisterClassDialog({
    super.key,
    required this.classItem,
    required this.subjectColor,
    required this.isRegistering,
    required this.isRegistered,
    this.registrationData,
    required this.onRegister,
    this.onCancel,
  });

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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Thông tin lớp:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          if (classItem.teacherName != null) Text('- Giáo viên: ${classItem.teacherName}'),
          Text('- Lịch học:'),
          if (classItem.schedule.isNotEmpty) ..._getScheduleDetails(classItem.schedule),
          if (classItem.pricePerSession != null) Text('- Học phí: ${_formatCurrency(classItem.pricePerSession!)} VNĐ/buổi'),
          if (classItem.location != null) Text('- Địa chỉ: ${classItem.location}'),
          if (classItem.description != null && classItem.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(classItem.description!, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
          if (isRegistered) _buildRegisteredStatus(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // gọi onCancel trước khi đóng dialog (để revert trạng thái trong Bloc)
            if (onCancel != null) onCancel!();
            Navigator.pop(context);
          },
          child: const Text('Hủy'),
        ),
        if (!isRegistered)
          ElevatedButton.icon(
            onPressed: isRegistering ? null : () { onRegister(); },
            icon: isRegistering
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Icon(Icons.person_add),
            label: Text(isRegistering ? 'Đang đăng ký...' : 'Đăng ký'),
            style: ElevatedButton.styleFrom(backgroundColor: subjectColor, foregroundColor: Colors.white),
          ),
      ],
    );
  }

  List<Widget> _getScheduleDetails(List<Schedule> schedule) {
    if (schedule.isEmpty) return [const Text('Chưa có lịch học')];
    return schedule.map((s) => Text('  + ${s.dayOfWeek} ${s.startTime}-${s.endTime}')).toList();
  }

  Widget _buildRegisteredStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green[300]!)),
      child: Row(children: [
        Icon(Icons.check_circle, color: Colors.green[600], size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text('Bạn đã đăng ký lớp này', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700]))),
      ]),
    );
  }

  static String _formatCurrency(num value) => value.toStringAsFixed(0);
}
