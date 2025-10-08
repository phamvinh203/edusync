import 'package:flutter/material.dart';
import 'join_class_form.dart';

class JoinClassDialog extends StatelessWidget {
  const JoinClassDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.qr_code_2, color: Colors.blue),
          SizedBox(width: 8),
          Text('Nhập mã lớp học'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhập mã lớp do giáo viên cung cấp để tham gia lớp học chính khóa.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Use the reusable form. When successful, close the dialog.
          JoinClassForm(onSuccess: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}
