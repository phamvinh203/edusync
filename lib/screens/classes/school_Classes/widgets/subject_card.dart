import 'package:edusync/models/class_model.dart';
import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final ClassModel classItem;
  final String userRole;

  const SubjectCard({Key? key, required this.classItem, required this.userRole})
    : super(key: key);

  Map<String, Map<String, dynamic>> _getSubjectStyles() {
    return {
      'toán': {'icon': Icons.calculate, 'color': Colors.blue},
      'vật lý': {'icon': Icons.science, 'color': Colors.green},
      'hóa': {'icon': Icons.biotech, 'color': Colors.orange},
      'văn': {'icon': Icons.menu_book, 'color': Colors.purple},
      'anh': {'icon': Icons.language, 'color': Colors.red},
      'lịch sử': {'icon': Icons.history_edu, 'color': Colors.brown},
      'địa': {'icon': Icons.map, 'color': Colors.teal},
      'sinh': {'icon': Icons.spa, 'color': Colors.lightGreen},
    };
  }

  Map<String, dynamic> _getSubjectStyle(String subject) {
    final lower = subject.toLowerCase();
    final styles = _getSubjectStyles();
    return styles.entries
        .firstWhere(
          (entry) => lower.contains(entry.key),
          orElse:
              () => const MapEntry('', {
                'icon': Icons.book,
                'color': Colors.grey,
              }),
        )
        .value;
  }

  @override
  Widget build(BuildContext context) {
    final style = _getSubjectStyle(classItem.subject);
    final icon = style['icon'] as IconData;
    final color = style['color'] as Color;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bạn đã chọn lớp ${classItem.nameClass}')),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.25)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon và badge ở trên
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      userRole == 'teacher' ? 'Đã tạo' : 'Đã tham gia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Text content ở dưới
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    classItem.subject,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    classItem.nameClass,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (userRole == 'student' &&
                      classItem.teacherName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'GV: ${classItem.teacherName}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
