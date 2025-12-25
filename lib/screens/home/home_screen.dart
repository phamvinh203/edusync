import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/home_model.dart';
import 'package:edusync/repositories/home_repository.dart';
import 'package:edusync/blocs/home/home_bloc.dart';
import 'package:edusync/blocs/home/home_event.dart';
import 'package:edusync/blocs/home/home_state.dart';
import 'package:edusync/screens/home/widgets/student_home_widgets.dart';
import 'package:edusync/screens/home/widgets/teacher_home_widgets.dart';
import 'package:edusync/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();

    // Khởi tạo HomeBloc một lần, giữ sống cùng HomeScreen (nhờ keepAlive)
    _homeBloc = HomeBloc(DashboardRepository());

    // Gọi load /users/me
    context.read<UserBloc>().add(const UserMeRequested());

    // Nếu AuthBloc đã có role ngay lập tức, schedule 1 lần load (sau frame)
    final authState = context.read<AuthBloc>().state;
    final initialRole = (authState.user?.role ?? '').toLowerCase();
    if (initialRole.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final isTeacher = initialRole == 'teacher';
        _homeBloc.add(LoadHome(isTeacher: isTeacher));
      });
    }
  }

  @override
  void dispose() {
    _homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        final userRole = (authState.user?.role ?? '').toLowerCase();
        if (userRole.isEmpty) return;
        // Khi role thay đổi (hoặc lần đầu có), yêu cầu HomeBloc nạp dữ liệu nếu chưa có
        final isTeacher = userRole == 'teacher';
        Future.microtask(() => _homeBloc.add(LoadHome(isTeacher: isTeacher)));
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
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
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
                                  Container(
                                    width: 120,
                                    height: 20,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 80,
                                    height: 16,
                                    color: Colors.grey[200],
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                              ),
                            ],
                          );
                        }

                        if (state.status == UserStatus.failure) {
                          return Text(
                            state.errorMessage ??
                                AppLocalizations.of(
                                  context,
                                )!.errorLoadingUserInfo,
                            style: theme.bodyMedium?.copyWith(
                              color: Colors.red,
                            ),
                          );
                        }

                        final username =
                            state.auth?.username ??
                            state.profile?.username ??
                            'Người dùng';
                        final avatarUrl = state.profile?.avatar;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.hello,
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
                                  (avatarUrl != null && avatarUrl.isNotEmpty)
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              child:
                                  (avatarUrl == null || avatarUrl.isEmpty)
                                      ? Text(
                                        (username.isNotEmpty
                                                ? username[0]
                                                : 'U')
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      : null,
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Dashboard content driven by HomeBloc (đảm bảo chỉ load 1 lần)
                    BlocProvider.value(
                      value: _homeBloc,
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          if (state is HomeLoading || state is HomeInitial) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (state is HomeError) {
                            return Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.cannotLoadData,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, authState) {
                                      final role =
                                          (authState.user?.role ?? '')
                                              .toLowerCase();
                                      return ElevatedButton.icon(
                                        onPressed: () => _manualRefresh(role),
                                        icon: const Icon(Icons.refresh),
                                        label: Text(
                                          AppLocalizations.of(context)!.reload,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state is HomeLoaded) {
                            // Ưu tiên hiển thị theo data có sẵn
                            if (state.studentHome != null) {
                              return _buildStudentDashboard(state.studentHome!);
                            }
                            if (state.teacherHome != null) {
                              return _buildTeacherDashboard(state.teacherHome!);
                            }
                          }

                          return const SizedBox.shrink();
                        },
                      ),
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

  Future<void> _refreshDashboard() async {
    final authState = context.read<AuthBloc>().state;
    final userRole = (authState.user?.role ?? '').toLowerCase();
    if (userRole.isEmpty) return;

    final isTeacher = userRole == 'teacher';
    _homeBloc.add(RefreshHome(isTeacher: isTeacher));

    // Chờ state khác Loading để kết thúc hiệu ứng RefreshIndicator
    await _homeBloc.stream.firstWhere((s) => s is! HomeLoading);
  }

  Future<void> _manualRefresh(String userRole) async {
    if (userRole.isEmpty) return;
    final isTeacher = userRole == 'teacher';
    _homeBloc.add(RefreshHome(isTeacher: isTeacher));
  }

  Widget _buildStudentDashboard(StudentDashboard dashboard) {
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

  Widget _buildTeacherDashboard(TeacherDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TeacherStatsRow(classStats: dashboard.classStats),
        const SizedBox(height: 16),
        TeacherPendingGradingRow(
          gradingStats: dashboard.gradingStats,
          todaySchedule: dashboard.todaySchedule,
        ),
        const SizedBox(height: 16),
        if (dashboard.todaySchedule.classes.isNotEmpty)
          TodayScheduleWidget(todaySchedule: dashboard.todaySchedule),
        const SizedBox(height: 16),
        QuickActionsSection(
          onCreateExercise: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.createExerciseFeatureInDevelopment,
                ),
              ),
            );
          },
          onTakeAttendance: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.takeAttendanceFeatureInDevelopment,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TeacherRecentActivitiesSection(activities: dashboard.recentActivities),
      ],
    );
  }
}
