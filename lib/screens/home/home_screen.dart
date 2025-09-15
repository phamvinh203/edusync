import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/home_model.dart';
import 'package:edusync/repositories/home_repository.dart';
import 'package:edusync/screens/home/widgets/student_home_widgets.dart';
import 'package:edusync/screens/home/widgets/teacher_home_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final DashboardRepository _dashboardRepo = DashboardRepository();

  StudentDashboard? _studentDashboard;
  TeacherDashboard? _teacherDashboard;
  bool _isLoadingDashboard = false;
  String? _dashboardError;

  String? _lastLoadedRole; // role đã load thành công trước đó
  String? _loadingRole; // role đang được load (tránh gọi đồng thời)

  @override
  void initState() {
    super.initState();

    // Gọi load /users/me
    context.read<UserBloc>().add(const UserMeRequested());

    // Nếu AuthBloc đã có role ngay lập tức, schedule 1 lần load (sau frame)
    final authState = context.read<AuthBloc>().state;
    final initialRole = authState.user?.role ?? '';
    if (initialRole.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final role = initialRole.toLowerCase();
        if (!_isLoadingDashboard && _lastLoadedRole != role) {
          _loadDashboard(role);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final userRole = (authState.user?.role ?? '').toLowerCase();
        if (userRole.isEmpty) return;

        // Nếu đang load cùng role thì return, hoặc đã có dữ liệu cho role đó thì return
        if (_isLoadingDashboard) return;
        if (_lastLoadedRole == userRole &&
            ((userRole == 'student' && _studentDashboard != null) ||
             (userRole == 'teacher' && _teacherDashboard != null))) {
          return;
        }

        // Schedule load (microtask để tránh gọi trong middle of build)
        Future.microtask(() => _loadDashboard(userRole));
      },
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (User info)
                    BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                      final theme = Theme.of(context).textTheme;

                      // --- NOTE: Không trả về Center lớn khi loading để tránh "2 spinner" ---
                      if (state.status == UserStatus.loading) {
                        // Hiện placeholder nhỏ thay vì full-screen spinner
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(width: 120, height: 20, color: Colors.grey[300]),
                                const SizedBox(height: 6),
                                Container(width: 80, height: 16, color: Colors.grey[200]),
                              ],
                            ),
                            CircleAvatar(radius: 25, backgroundColor: Colors.grey[300]),
                          ],
                        );
                      }

                      if (state.status == UserStatus.failure) {
                        return Text(
                          state.errorMessage ?? 'Lỗi tải thông tin người dùng',
                          style: theme.bodyMedium?.copyWith(color: Colors.red),
                        );
                      }

                      final username =
                          state.auth?.username ?? state.profile?.username ?? 'Người dùng';
                      final avatarUrl = state.profile?.avatar;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào!',
                                style: theme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                username,
                                style: theme.titleMedium?.copyWith(
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.blue[100],
                            backgroundImage:
                                (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                    (username.isNotEmpty ? username[0] : 'U').toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Dashboard content based on user role
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) => previous.user?.role != current.user?.role,
                      builder: (context, authState) {
                        final userRole = (authState.user?.role ?? '').toLowerCase();

                        // Nếu đang load dashboard -> hiển thị spinner chính giữa
                        if (_isLoadingDashboard) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (_dashboardError != null) {
                          return Center(
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                                const SizedBox(height: 16),
                                const Text('Không thể tải dữ liệu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text(_dashboardError!, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () => _manualRefresh(userRole),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tải lại'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (userRole == 'student') {
                          return _buildStudentDashboard();
                        } else if (userRole == 'teacher') {
                          return _buildTeacherDashboard();
                        } else {
                          return const Center(child: Text('Role không được hỗ trợ'));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadDashboard(String userRole) async {
    // Guard: nếu đang load hoặc đang load cho chính role đó thì tránh gọi tiếp
    if (_isLoadingDashboard || (_loadingRole != null && _loadingRole == userRole)) return;

    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
      _loadingRole = userRole;
    });

    try {
      if (userRole == 'student') {
        final dashboard = await _dashboardRepo.getStudentDashboard();
        if (!mounted) return;
        setState(() {
          _studentDashboard = dashboard;
          _lastLoadedRole = userRole;
        });
      } else if (userRole == 'teacher') {
        final dashboard = await _dashboardRepo.getTeacherDashboard();
        if (!mounted) return;
        setState(() {
          _teacherDashboard = dashboard;
          _lastLoadedRole = userRole;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _dashboardError = e.toString();
        // không set _lastLoadedRole để có thể thử lại sau
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingDashboard = false;
        _loadingRole = null;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    final authState = context.read<AuthBloc>().state;
    final userRole = (authState.user?.role ?? '').toLowerCase();
    if (userRole.isNotEmpty) await _manualRefresh(userRole);
  }

  Future<void> _manualRefresh(String userRole) async {
    setState(() {
      _studentDashboard = null;
      _teacherDashboard = null;
      _dashboardError = null;
      _lastLoadedRole = null; // reset để bắt buộc reload
    });
    await _loadDashboard(userRole);
  }

  Widget _buildStudentDashboard() {
    if (_studentDashboard == null) return const SizedBox.shrink();
    final dashboard = _studentDashboard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudentStatsRow(
          todayAssignmentsCount: dashboard.todayAssignments.length,
          totalClassesJoined: dashboard.totalClassesJoined,
        ),
        const SizedBox(height: 16),
        if (dashboard.todayAssignments.isNotEmpty)
          TodayAssignmentsWidget(assignments: dashboard.todayAssignments),
        const SizedBox(height: 16),
        RecentActivitiesSection(activities: dashboard.recentActivities),
      ],
    );
  }

  Widget _buildTeacherDashboard() {
    if (_teacherDashboard == null) return const SizedBox.shrink();
    final dashboard = _teacherDashboard!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeacherStatsRow(classStats: dashboard.classStats),
        const SizedBox(height: 16),
        TeacherPendingGradingRow(gradingStats: dashboard.gradingStats, todaySchedule: dashboard.todaySchedule),
        const SizedBox(height: 16),
        if (dashboard.todaySchedule.classes.isNotEmpty)
          TodayScheduleWidget(todaySchedule: dashboard.todaySchedule),
        const SizedBox(height: 16),
        QuickActionsSection(onCreateExercise: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng tạo bài tập đang được phát triển')));
        }, onTakeAttendance: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chức năng điểm danh đang được phát triển')));
        }),
        const SizedBox(height: 16),
        TeacherRecentActivitiesSection(activities: dashboard.recentActivities),
      ],
    );
  }
}
