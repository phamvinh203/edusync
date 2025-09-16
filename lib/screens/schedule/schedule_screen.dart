import 'package:flutter/material.dart';
import 'package:edusync/models/schedule_model.dart';
import 'package:edusync/repositories/schedule_repository.dart';
import 'package:edusync/screens/schedule/schedule_event.dart';
import 'package:edusync/screens/schedule/widgets/week_header.dart';
import 'package:edusync/screens/schedule/widgets/week_list.dart';
// Month view removed; only week view retained

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  List<ClassSchedule> _classSchedules = [];
  bool _isLoading = true;
  String? _errorMessage;
  // Keep only week view
  late DateTime _weekStart; // Monday of the current week

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(DateTime.now());
    _loadSchedules();
  }

  // No extra resources to dispose

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _scheduleRepository.getClassSchedules();
      setState(() {
        _classSchedules = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Month events generation removed; week view builds per-week

  // --- Helpers for week view ---
  DateTime _getWeekStart(DateTime date) {
    // Make Monday the start of week
    final int weekday = date.weekday; // Mon=1..Sun=7
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday - DateTime.monday));
  }

  int? _weekdayFromString(String day) {
    final key = day.trim().toLowerCase();
    switch (key) {
      case 'chủ nhật':
      case 'chu nhat':
      case 'cn':
      case 'sunday':
        return DateTime.sunday;
      case 'thứ 2':
      case 'thu 2':
      case 't2':
      case 'monday':
        return DateTime.monday;
      case 'thứ 3':
      case 'thu 3':
      case 't3':
      case 'tuesday':
        return DateTime.tuesday;
      case 'thứ 4':
      case 'thu 4':
      case 't4':
      case 'wednesday':
        return DateTime.wednesday;
      case 'thứ 5':
      case 'thu 5':
      case 't5':
      case 'thursday':
        return DateTime.thursday;
      case 'thứ 6':
      case 'thu 6':
      case 't6':
      case 'friday':
        return DateTime.friday;
      case 'thứ 7':
      case 'thu 7':
      case 't7':
      case 'saturday':
        return DateTime.saturday;
      default:
        return null;
    }
  }

  Map<DateTime, List<ScheduleEvent>> _getEventsForWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 6));
    final map = <DateTime, List<ScheduleEvent>>{};

    for (final classSchedule in _classSchedules) {
      for (final s in classSchedule.schedule) {
        final wd = _weekdayFromString(s.dayOfWeek);
        if (wd == null) continue;
        // For each day in the week, add matching weekday
        for (
          DateTime d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))
        ) {
          if (d.weekday == wd) {
            final dayKey = DateTime(d.year, d.month, d.day);
            (map[dayKey] ??= []).add(
              ScheduleEvent(classSchedule: classSchedule, schedule: s),
            );
          }
        }
      }
    }

    // Sort events in each day by start time
    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        int parseHHMM(String s) {
          final parts = s.split(':');
          if (parts.length != 2) return 0;
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          return h * 60 + m;
        }

        return parseHHMM(
          a.schedule.startTime,
        ).compareTo(parseHHMM(b.schedule.startTime));
      });
    }

    return map;
  }

  // Month/day helpers removed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedules,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi khi tải lịch học',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSchedules,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  WeekHeader(
                    weekStart: _weekStart,
                    onPrevWeek:
                        () => setState(() {
                          _weekStart = _weekStart.subtract(
                            const Duration(days: 7),
                          );
                        }),
                    onNextWeek:
                        () => setState(() {
                          _weekStart = _weekStart.add(const Duration(days: 7));
                        }),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: WeekList(
                      eventsByDay: _getEventsForWeek(_weekStart),
                      weekStart: _weekStart,
                      subjectColor: _getSubjectColor,
                    ),
                  ),
                ],
              ),
    );
  }

  Color _getSubjectColor(String subject) {
    // Tạo màu dựa trên tên môn học
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    if (subject.isEmpty) {
      return colors[0]; // Trả về màu mặc định nếu subject rỗng
    }

    final hash = subject.toLowerCase().codeUnits.fold(
      0,
      (prev, element) => prev + element,
    );
    return colors[hash % colors.length];
  }
}
