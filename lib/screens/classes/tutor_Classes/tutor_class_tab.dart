import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/screens/classes/tutor_Classes/class_detail_screen.dart';
import 'package:edusync/repositories/class_repository.dart';

class TutorClassTab extends StatefulWidget {
  const TutorClassTab({super.key});

  @override
  State<TutorClassTab> createState() => _TutorClassTabState();
}

class _TutorClassTabState extends State<TutorClassTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Giữ state khi chuyển tab

  @override
  void initState() {
    super.initState();
    // Chỉ load data nếu chưa có data hoặc là lần đầu
    final currentState = context.read<ClassBloc>().state;
    final authState = context.read<AuthBloc>().state;
    final userRole = authState.user?.role ?? '';
    // Với học sinh: luôn lấy danh sách lớp đã được duyệt (tránh dùng cache lớp "tất cả")
    if (userRole.toLowerCase() == 'student') {
      context.read<ClassBloc>().add(GetRegisteredClassesEvent());
    } else {
      // Với role khác: chỉ load khi chưa có dữ liệu
      if (currentState is! ClassLoaded && currentState is! ClassCreateSuccess) {
        context.read<ClassBloc>().add(LoadClassesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userRole = authState.user?.role ?? '';

        return BlocBuilder<ClassBloc, ClassState>(
          builder: (context, state) {
            // loading
            if (state is ClassLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            // error
            if (state is ClassError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (userRole.toLowerCase() == 'student') {
                          context.read<ClassBloc>().add(
                            GetRegisteredClassesEvent(),
                          );
                        } else {
                          context.read<ClassBloc>().add(LoadClassesEvent());
                        }
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            // Lấy danh sách lớp học từ state
            // success
            List<ClassModel> classes = [];
            if (state is ClassLoaded) {
              classes = state.classes;
            } else if (state is ClassCreateSuccess) {
              classes = state.allClasses;
            }

            // Nếu không có lớp học nào
            if (classes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userRole.toLowerCase() == 'student'
                          ? 'Chưa đăng ký lớp gia sư nào'
                          : 'Chưa có lớp gia sư nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userRole.toLowerCase() == 'student'
                          ? 'Tìm và đăng ký lớp gia sư'
                          : 'Tạo lớp gia sư đầu tiên của bạn',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            // Hiển thị danh sách lớp học với khả năng refresh
            return RefreshIndicator(
              onRefresh: () async {
                if (userRole.toLowerCase() == 'student') {
                  context.read<ClassBloc>().add(GetRegisteredClassesEvent());
                } else {
                  context.read<ClassBloc>().add(RefreshClassesEvent());
                }
              },
              child: Column(
                children: [
                  // Thêm 2 nút cho student
                  if (userRole.toLowerCase() == 'student') ...[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showAvailableClassesBottomSheet(
                                  context,
                                  classes,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.search, size: 18),
                              label: const Text(
                                'Tìm lớp gia sư',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // _showAvailableClassesBottomSheet(context, classes);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                                padding: const EdgeInsets.all(12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.pending_actions, size: 18),
                              label: const Text(
                                'Đơn đăng ký',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Danh sách lớp học
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final classItem = classes[index];
                        return _buildClassCard(
                          classItem,
                          userRole.toLowerCase(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildClassCard(ClassModel classItem, String userRole) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          // Điều hướng đến màn hình chi tiết lớp học
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ClassDetailScreen(
                    classId: classItem.id ?? '',
                    className: classItem.nameClass,
                    userRole: userRole,
                  ),
            ),
          );

          // Nếu có thay đổi (xóa lớp thành công), refresh lại danh sách
          if (result == true && mounted) {
            if (userRole.toLowerCase() == 'student') {
              // Với học sinh: luôn refresh danh sách lớp đã được duyệt
              context.read<ClassBloc>().add(GetRegisteredClassesEvent());
            } else {
              context.read<ClassBloc>().add(RefreshClassesEvent());
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với tên lớp và môn học
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classItem.nameClass,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classItem.subject,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[600],
                          ),
                        ),
                        // Hiển thị tên giáo viên
                        if (classItem.teacherName != null &&
                            classItem.teacherName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'GV: ${classItem.teacherName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${classItem.students.length}/${classItem.maxStudents ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Mô tả (nếu có)
              if (classItem.description != null &&
                  classItem.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  classItem.description!,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Thông tin thêm
              const SizedBox(height: 12),
              Row(
                children: [
                  // Lịch học
                  if (classItem.schedule.isNotEmpty) ...[
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _getScheduleText(classItem.schedule),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Địa điểm (nếu có)
                  if (classItem.location != null &&
                      classItem.location!.isNotEmpty) ...[
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        classItem.location!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              // Thời gian tạo
              const SizedBox(height: 8),
              Text(
                'Tạo: ${_formatDate(classItem.createdAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScheduleText(List<Schedule> schedule) {
    if (schedule.isEmpty) return '';

    if (schedule.length == 1) {
      final s = schedule.first;
      return '${s.dayOfWeek} ${s.startTime}-${s.endTime}';
    }

    return '${schedule.length} buổi/tuần';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Không rõ';

    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';

    return '${date.day}/${date.month}/${date.year}';
  }

  // Hàm hiển thị bottom sheet với danh sách lớp học available cho student
  void _showAvailableClassesBottomSheet(
    BuildContext context,
    List<ClassModel> classes,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Cho phép scroll và mở rộng toàn màn hình nếu cần
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // Bo góc trên
      ),
      builder: (BuildContext bottomSheetContext) {
        return DraggableScrollableSheet(
          expand: false, // Không mở rộng tự động toàn màn hình
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header của bottom sheet
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Danh các sách lớp gia sư',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Danh sách tất cả lớp (fetch trực tiếp từ repository cho bottom sheet)
                  Expanded(
                    child: FutureBuilder<List<ClassModel>>(
                      future: ClassRepository().getAllClasses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải danh sách lớp: ${snapshot.error}',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        final allClasses = snapshot.data ?? [];
                        if (allClasses.isEmpty) {
                          return const Center(child: Text('Không có lớp nào'));
                        }
                        return ListView.builder(
                          controller:
                              scrollController, // Kết nối scroll với Draggable
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: allClasses.length,
                          itemBuilder: (context, index) {
                            final classItem = allClasses[index];
                            return _buildClassCard(classItem, 'student');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
