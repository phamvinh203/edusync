import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/screens/classes/create_class_screen.dart';
import 'package:edusync/screens/classes/school_subject_tab.dart';
import 'package:edusync/screens/classes/tutor_class_tab.dart';
import 'package:edusync/models/class_model.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    if (mounted) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Kiểm tra mounted trước khi sử dụng context
        if (!mounted) return const SizedBox.shrink();

        // Lấy thông tin profile từ UserBloc
        final userClass = userState.profile?.userClass ?? 'Chưa cập nhật lớp';
        final userSchool =
            userState.profile?.userSchool ?? 'Chưa cập nhật trường';

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Lấy role từ AuthBloc
            final userRole = authState.user?.role ?? '';

            return Scaffold(
              appBar: AppBar(
                title: const Text('Lớp học'),
                actions: [
                  // Chỉ hiển thị nút tạo lớp học cho giáo viên
                  if (userRole.toLowerCase() == 'teacher')
                    IconButton(
                      onPressed: () async {
                        if (!mounted) return;
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateClassScreen(),
                          ),
                        );
                        // Nếu tạo lớp thành công, cập nhật danh sách
                        if (result is ClassModel && mounted) {
                          // Refresh danh sách lớp học từ server
                          context.read<ClassBloc>().add(RefreshClassesEvent());

                          // Chuyển sang tab "Lớp gia sư" để hiển thị lớp vừa tạo
                          _tabController.animateTo(1);

                          // Hiển thị thông báo thành công
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã tạo lớp "${result.nameClass}" thành công!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Tạo lớp học mới',
                    ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    // thông tin lớp học
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16.0),
                          // Quick info card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lớp: $userClass',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Trường: $userSchool',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _buildCardClass('6 môn học', Icons.book),
                                    const SizedBox(width: 12),
                                    _buildCardClass(
                                      '2 lớp gia sư',
                                      Icons.person,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildCardClass(
                                      '12 bài tập',
                                      Icons.assignment,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tab bar and schedule button
                          Row(
                            children: [
                              Expanded(
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor: Colors.blue[600],
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Colors.blue[600],
                                  tabs: const [
                                    Tab(
                                      text: 'Môn học trường',
                                      icon: Icon(Icons.school, size: 20),
                                    ),
                                    Tab(
                                      text: 'Lớp gia sư',
                                      icon: Icon(Icons.person, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              TextButton.icon(
                                onPressed: () {
                                  if (!mounted) return;
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder:
                                  //         (context) => const StudentScheduleScreen(),
                                  //   ),
                                  // );
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                ),
                                label: const Text('Lịch học'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TabBarView - Nội dung các tab
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          SchoolSubjectTab(), // Tab môn học trường
                          TutorClassTab(), // Tab lớp gia sư
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardClass(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
