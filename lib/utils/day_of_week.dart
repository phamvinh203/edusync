import 'package:edusync/models/class_model.dart';

String getVietnameseDayOfWeek(String dayOfWeek) {
  const dayMap = {
    'Monday': 'Thứ 2',
    'Tuesday': 'Thứ 3',
    'Wednesday': 'Thứ 4',
    'Thursday': 'Thứ 5',
    'Friday': 'Thứ 6',
    'Saturday': 'Thứ 7',
    'Sunday': 'Chủ nhật',
  };
  return dayMap[dayOfWeek] ?? dayOfWeek;
}

String getScheduleText(List<Schedule> schedule) {
  if (schedule.isEmpty) return '';

  if (schedule.length == 1) {
    final s = schedule.first;
    return '${getVietnameseDayOfWeek(s.dayOfWeek)} ${s.startTime}-${s.endTime}';
  }

  return '${schedule.length} buổi/tuần';
}

String formatDate(DateTime? date) {
  if (date == null) return 'Không rõ';

  final now = DateTime.now();
  final diff = now.difference(date).inDays;

  if (diff == 0) return 'Hôm nay';
  if (diff == 1) return 'Hôm qua';
  if (diff < 7) return '$diff ngày trước';

  return '${date.day}/${date.month}/${date.year}';
}
