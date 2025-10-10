import 'package:edusync/blocs/AvailableClasses/availableClasses_bloc.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_event.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_bloc.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_event.dart';
import 'package:edusync/blocs/RegisteredClasses/registeredClasses_state.dart';
import 'package:edusync/screens/classes/tutor_classes/teacher/screens/create_class_screen.dart';
import 'package:edusync/screens/classes/widgets/quick_info_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/screens/schedule/schedule_screen.dart';
import 'package:edusync/screens/classes/school_Classes/school_subject_tab.dart';
import 'package:edusync/screens/classes/tutor_classes/tutor_class_tab.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/l10n/app_localizations.dart';

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

    // Load danh sách lớp học để hiển thị số lượng
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<ClassBloc>().add(LoadClassesEvent());
    //
    //     // Chỉ load số lượng lớp đã đăng ký nếu là student
    //     final authState = context.read<AuthBloc>().state;
    //     final userRole = authState.user?.role ?? '';
    //     if (userRole.toLowerCase() == 'student') {
    //       context.read<ClassBloc>().add(LoadRegisteredClassesCountEvent());
    //     }
    //   }
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClassBloc>().add(LoadClassesEvent());
        // load available classes once
        context.read<AvailableClassesBloc>().add(LoadAvailableClassesEvent());

        final authState = context.read<AuthBloc>().state;
        final userRole = authState.user?.role ?? '';
        if (userRole.toLowerCase() == 'student') {
          context.read<RegisteredClassesBloc>().add(
            LoadRegisteredClassesEvent(),
          );
          // Load số lượng lớp đã đăng ký cho hiển thị trong QuickInfoCard
          context.read<ClassBloc>().add(LoadRegisteredClassesCountEvent());
        }
      }
    });
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
        final userClass =
            userState.profile?.userClass ??
            AppLocalizations.of(context)!.classNotUpdated;
        final userSchool =
            userState.profile?.userSchool ??
            AppLocalizations.of(context)!.schoolNotUpdated;

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Lấy role từ AuthBloc
            final userRole = authState.user?.role ?? '';

            return BlocBuilder<ClassBloc, ClassState>(
              builder: (context, classState) {
                // Lấy số lượng dựa theo role
                int classCount = 0;
                String classLabel = '';

                if (userRole.toLowerCase() == 'student') {
                  // Học sinh: hiển thị số lớp đã đăng ký
                  if (classState is ClassLoaded) {
                    classCount = classState.registeredClassesCount;
                  }
                  classLabel = AppLocalizations.of(context)!.tutorClasses;
                } else if (userRole.toLowerCase() == 'teacher') {
                  // Giáo viên: hiển thị số lớp đã tạo
                  if (classState is ClassLoaded) {
                    classCount = classState.classes.length;
                  }
                  classLabel = AppLocalizations.of(context)!.createdClasses;
                } else {
                  // Role khác hoặc chưa xác định
                  classLabel = AppLocalizations.of(context)!.classes;
                }

                return Scaffold(
                  body: Column(
                    children: [
                      // thông tin lớp học
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16.0),
                            // Quick info card
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: QuickInfoCard(
                                userClass: userClass,
                                userSchool: userSchool,
                                classCount: classCount,
                                classLabel: classLabel,
                                userRole: userRole,
                                onCreateClass: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const CreateClassScreen(),
                                    ),
                                  );

                                  if (result is ClassModel && mounted) {
                                    context.read<ClassBloc>().add(
                                      RefreshClassesEvent(),
                                    );

                                    // Cập nhật AvailableClassesBloc để học sinh có thể thấy lớp mới
                                    context.read<AvailableClassesBloc>().add(
                                      RefreshAvailableClassesEvent(),
                                    );

                                    if (userRole.toLowerCase() == 'student') {
                                      context.read<ClassBloc>().add(
                                        LoadRegisteredClassesCountEvent(),
                                      );
                                    }

                                    _tabController.animateTo(1);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.classCreatedSuccess(
                                            result.nameClass,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
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
                                    tabs: [
                                      Tab(
                                        text:
                                            AppLocalizations.of(
                                              context,
                                            )!.schoolSubjects,
                                        icon: const Icon(
                                          Icons.school,
                                          size: 20,
                                        ),
                                      ),
                                      Tab(
                                        text:
                                            AppLocalizations.of(
                                              context,
                                            )!.tutorClassesTab,
                                        icon: const Icon(
                                          Icons.person,
                                          size: 20,
                                        ),
                                      ),
                                      // Tab(
                                      //   text: 'Lớp đã đăng ký',
                                      //   icon: Icon(Icons.person, size: 20),
                                      // ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ScheduleScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.schedule,
                                  ),
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
                          children: [
                            // Tab môn học trường với PageStorageKey
                            Container(
                              key: const PageStorageKey('school_tab'),
                              child: const SchoolSubjectTab(),
                            ),
                            // Tab lớp gia sư với PageStorageKey
                            Container(
                              key: const PageStorageKey('tutor_tab'),
                              child: const TutorClassTab(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
