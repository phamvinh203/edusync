import 'package:flutter/material.dart';
import 'package:edusync/models/schedule_response_model.dart';
import 'package:edusync/repositories/schedule_repository.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Map<DateTime, List<ScheduleEvent>> _events;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _events = {};
    _loadSchedules();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        _generateEvents();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _generateEvents() {
    _events.clear();

    // Map thứ trong tuần từ tiếng Việt sang số
    Map<String, int> dayOfWeekMap = {
      'Chủ nhật': DateTime.sunday,
      'Thứ 2': DateTime.monday,
      'Thứ 3': DateTime.tuesday,
      'Thứ 4': DateTime.wednesday,
      'Thứ 5': DateTime.thursday,
      'Thứ 6': DateTime.friday,
      'Thứ 7': DateTime.saturday,
    };

    for (var classSchedule in _classSchedules) {
      if (classSchedule.schedule.isNotEmpty) {
        for (var schedule in classSchedule.schedule) {
          if (schedule.dayOfWeek.isNotEmpty) {
            int? dayOfWeek = dayOfWeekMap[schedule.dayOfWeek];
            if (dayOfWeek != null) {
              // Tạo event cho 4 tuần tới
              DateTime startDate = DateTime.now();
              for (int i = 0; i < 28; i++) {
                DateTime currentDate = startDate.add(Duration(days: i));
                if (currentDate.weekday == dayOfWeek) {
                  DateTime eventDate = DateTime(
                    currentDate.year,
                    currentDate.month,
                    currentDate.day,
                  );

                  _events[eventDate] ??= [];
                  _events[eventDate]!.add(
                    ScheduleEvent(classSchedule: classSchedule, schedule: schedule),
                  );
                }
              }
            }
          }
        }
      }
    }
  }

  List<ScheduleEvent> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildCalendarWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [_buildCalendarHeader(), _buildCalendarGrid()]),
    );
  }

  Widget _buildCalendarHeader() {
    List<String> months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            '${months[_focusedDay.month - 1]} ${_focusedDay.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    List<String> weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    DateTime firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    DateTime lastDayOfMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    );

    int firstWeekday = firstDayOfMonth.weekday;
    int daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Header với tên các thứ
    for (String weekday in weekdays) {
      dayWidgets.add(
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            weekday,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Thêm các ô trống cho những ngày trước ngày 1
    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Thêm các ngày trong tháng
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime dayDate = DateTime(_focusedDay.year, _focusedDay.month, day);
      List<ScheduleEvent> events = _getEventsForDay(dayDate);
      bool isSelected = _isSameDay(_selectedDay, dayDate);
      bool isToday = _isSameDay(DateTime.now(), dayDate);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = dayDate;
            });
          },
          child: Container(
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.blue
                      : isToday
                      ? Colors.blue.withOpacity(0.1)
                      : null,
              borderRadius: BorderRadius.circular(8),
              border:
                  isToday && !isSelected
                      ? Border.all(color: Colors.blue)
                      : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : isToday
                              ? Colors.blue
                              : Colors.black,
                      fontWeight:
                          isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                  ),
                ),
                if (events.isNotEmpty)
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          events.take(3).map((event) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : _getSubjectColor(
                                          event.classSchedule.subject,
                                        ),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        children: dayWidgets,
      ),
    );
  }

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
                  // Custom Calendar Widget
                  _buildCalendarWidget(),
                  const SizedBox(height: 8.0),
                  // Events List
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _selectedDay != null
                                  ? 'Lịch học ngày ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}'
                                  : 'Chọn ngày để xem lịch học',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child:
                                _selectedDay != null
                                    ? _buildEventsList()
                                    : const Center(
                                      child: Text('Chọn ngày để xem lịch học'),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);

    if (events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có lịch học',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSubjectColor(event.classSchedule.subject),
              child: Text(
                event.classSchedule.subject.isNotEmpty 
                    ? event.classSchedule.subject.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              event.classSchedule.nameClass,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${event.classSchedule.subject} - ${event.classSchedule.gradeLevel}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.schedule.duration,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      event.classSchedule.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'GV: ${event.classSchedule.teacher.username}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSubjectColor(
                  event.classSchedule.subject,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSubjectColor(event.classSchedule.subject),
                  width: 1,
                ),
              ),
              child: Text(
                event.schedule.dayOfWeek,
                style: TextStyle(
                  color: _getSubjectColor(event.classSchedule.subject),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
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

class ScheduleEvent {
  final ClassSchedule classSchedule;
  final Schedule schedule;

  ScheduleEvent({required this.classSchedule, required this.schedule});
}
