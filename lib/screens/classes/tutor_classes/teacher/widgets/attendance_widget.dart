import 'package:flutter/material.dart';
import 'package:edusync/models/attendance_model.dart';
import 'package:edusync/repositories/attendance_repository.dart';
import 'package:edusync/models/users_model.dart';

class AttendanceTab extends StatefulWidget {
  final String classId;
  final List<UserProfile> students; // students of class to display names

  const AttendanceTab({
    super.key,
    required this.classId,
    required this.students,
  });

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final AttendanceRepository _repo = AttendanceRepository();
  bool _isStarting = false;
  bool _isMarking = false;
  bool _loadingHistory = false;
  AttendanceSession? _currentSession;
  AttendanceHistoryResponse? _history;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (mounted) setState(() => _loadingHistory = true);
    try {
      final res = await _repo.history(widget.classId);
      if (mounted) setState(() => _history = res);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _startAttendance() async {
    final parentContext = context;
    if (mounted) setState(() => _isStarting = true);
    try {
      // Reuse today's open session if exists
      await _loadHistory();
      AttendanceSession? todayOpen;
      final today = DateTime.now();
      for (final s in _history?.data ?? const <AttendanceSession>[]) {
        final sameDay =
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day;
        if (sameDay && s.status.toLowerCase() == 'open') {
          todayOpen = s;
          break;
        }
      }
      if (todayOpen != null) {
        if (!mounted) return; // widget might be disposed during await
        setState(() => _currentSession = todayOpen);
        await _openAttendanceDialogPrefilled(todayOpen);
        return;
      }

      // Start new
      final res = await _repo.startSession(widget.classId);
      if (!mounted) return;
      setState(() => _currentSession = res.data);
      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: Colors.green),
        );
      }
      await _openAttendanceDialogPrefilled(res.data);
    } catch (e) {
      if (mounted && parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.today, color: Colors.blue, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Điểm danh hôm nay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ngày ${today.day}/${today.month}/${today.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isStarting ? null : _startAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isStarting
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Điểm danh'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildHistoryCard()),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    if (_loadingHistory)
      return const Center(child: CircularProgressIndicator());
    final history = _history?.data ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử điểm danh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  history.isEmpty
                      ? const Center(child: Text('Chưa có lịch sử'))
                      : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final s = history[index];
                          final presentCount =
                              s.students
                                  .where(
                                    (e) => e.status.toLowerCase() == 'present',
                                  )
                                  .length;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Icon(
                                Icons.check,
                                color: Colors.green[600],
                              ),
                            ),
                            title: Text(
                              'Ngày ${s.date.day}/${s.date.month}/${s.date.year}',
                            ),
                            subtitle: Text(
                              '$presentCount / ${s.students.length} có mặt',
                            ),
                            onTap: () => _openAttendanceDialogForSession(s),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAttendanceDialogForSession(AttendanceSession session) async {
    final prev = _currentSession;
    setState(() => _currentSession = session);
    await _openAttendanceDialogPrefilled(session);
    if (mounted) setState(() => _currentSession = prev);
  }

  Future<void> _openAttendanceDialogPrefilled(AttendanceSession session) async {
    // Keep a stable reference to the parent widget context for SnackBars
    final parentContext = context;
    final nameMap = <String, String>{};
    for (final s in widget.students) {
      final id = s.id;
      if (id != null) nameMap[id] = s.username ?? s.email ?? id;
    }
    final selections = <String, bool>{
      for (final e in session.students)
        e.studentId: e.status.toLowerCase() == 'present',
    };
    await showDialog<void>(
      context: parentContext,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (dialogContext, setStateDialog) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: const Text('Điểm danh lớp học'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: session.students.length,
                            separatorBuilder:
                                (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final e = session.students[index];
                              final displayName =
                                  nameMap[e.studentId] ?? e.studentId;
                              final checked = selections[e.studentId] ?? false;
                              return ListTile(
                                title: Text(displayName),
                                subtitle: Text(
                                  'Email: ${widget.students.firstWhere((u) => u.id == e.studentId, orElse: () => const UserProfile()).email ?? ''}',
                                ),
                                trailing: Checkbox(
                                  value: checked,
                                  onChanged:
                                      (val) => setStateDialog(
                                        () =>
                                            selections[e.studentId] =
                                                val ?? false,
                                      ),
                                ),
                                onTap:
                                    () => setStateDialog(
                                      () =>
                                          selections[e.studentId] =
                                              !(selections[e.studentId] ??
                                                  false),
                                    ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      onPressed:
                          _isMarking
                              ? null
                              : () async {
                                final updates =
                                    session.students
                                        .where(
                                          (e) =>
                                              selections[e.studentId] == true,
                                        )
                                        .map(
                                          (e) => AttendanceStudentEntry(
                                            studentId: e.studentId,
                                            status: 'present',
                                          ),
                                        )
                                        .toList();
                                try {
                                  if (mounted)
                                    setState(() => _isMarking = true);
                                  final res = await _repo.mark(
                                    session.id,
                                    updates,
                                  );
                                  if (!mounted) return;
                                  {
                                    if (_currentSession?.id == session.id) {
                                      setState(
                                        () => _currentSession = res.data,
                                      );
                                    }
                                  }
                                  if (dialogContext.mounted)
                                    Navigator.of(dialogContext).pop();
                                  await _loadHistory();
                                  if (!mounted || !parentContext.mounted)
                                    return;
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(res.message),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted || !parentContext.mounted)
                                    return;
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceFirst(
                                          'Exception: ',
                                          '',
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted)
                                    setState(() => _isMarking = false);
                                }
                              },
                      child: const Text('Lưu điểm danh'),
                    ),
                  ],
                ),
          ),
    );
  }
}
