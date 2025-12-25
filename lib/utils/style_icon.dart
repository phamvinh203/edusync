import 'package:flutter/material.dart';

Map<String, Map<String, dynamic>> getSubjectStyles() {
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

Color getSubjectColor(String? subject) {
  final s = (subject ?? '').toLowerCase();
  final entry = getSubjectStyles().entries.firstWhere(
    (e) => s.contains(e.key),
    orElse:
        () => MapEntry('khác', {
          'icon': Icons.pending_actions,
          'color': Colors.orange,
        }),
  );
  return entry.value['color'] as Color;
}

IconData getSubjectIcon(String? subject) {
  final s = (subject ?? '').toLowerCase();
  final entry = getSubjectStyles().entries.firstWhere(
    (e) => s.contains(e.key),
    orElse:
        () => MapEntry('khác', {
          'icon': Icons.pending_actions,
          'color': Colors.orange,
        }),
  );
  return entry.value['icon'] as IconData;
}
