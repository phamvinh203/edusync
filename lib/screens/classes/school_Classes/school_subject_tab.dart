import 'package:flutter/material.dart';

class SchoolSubjectTab extends StatefulWidget {
  const SchoolSubjectTab({super.key});

  @override
  State<SchoolSubjectTab> createState() => _SchoolSubjectTabState();
}

class _SchoolSubjectTabState extends State<SchoolSubjectTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Giữ state khi chuyển tab

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Quan trọng: phải gọi super.build cho AutomaticKeepAliveClientMixin

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Môn học trường',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tính năng đang được phát triển',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
