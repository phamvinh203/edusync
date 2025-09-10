// Widget hiển thị trạng thái trống khi không có lớp học nào.

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String userRole;

  const EmptyStateWidget({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.class_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  userRole.toLowerCase() == 'student'
                      ? 'Chưa đăng ký lớp gia sư nào'
                      : 'Chưa có lớp gia sư nào',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userRole.toLowerCase() == 'student'
                      ? 'Tìm và đăng ký lớp gia sư phù hợp'
                      : 'Tạo lớp gia sư đầu tiên của bạn',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}