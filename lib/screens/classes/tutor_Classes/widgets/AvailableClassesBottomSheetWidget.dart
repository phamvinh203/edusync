// Widget hiển thị bottom sheet danh sách lớp học có sẵn
import 'package:edusync/screens/classes/tutor_Classes/available_class_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/blocs/class/class_bloc.dart';
import 'package:edusync/blocs/class/class_state.dart';
import 'package:edusync/blocs/class/class_event.dart';
import 'package:edusync/screens/classes/tutor_Classes/widgets/show_register_dialog.dart';

class AvailableClassesBottomSheet extends StatelessWidget {
  final List<ClassModel> classes;

  const AvailableClassesBottomSheet({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Danh sách lớp gia sư',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<ClassModel>>(
                  future: ClassRepository().getAllClasses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
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
                    final availableClasses = allClasses.where((classItem) {
                      final currentStudents = classItem.students.length;
                      final maxStudents = classItem.maxStudents ?? 0;
                      return currentStudents < maxStudents;
                    }).toList();

                    if (availableClasses.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Hiện tại chưa có lớp gia sư nào',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: availableClasses.length,
                      itemBuilder: (context, index) {
                        final classItem = availableClasses[index];
                        return AvailableClassCard(
                          classItem: classItem,
                          onRegister: (classItem, color) {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return BlocListener<ClassBloc, ClassState>(
                                  listener: (context, state) {
                                    if (state is ClassJoinSuccess) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đăng ký lớp thành công! Vui lòng chờ giáo viên duyệt.',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                    } else if (state is ClassError || state is ClassJoinError) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi: ${state is ClassError ? state.message : (state as ClassJoinError).message}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: RegisterClassDialog(
                                    classItem: classItem,
                                    subjectColor: color,
                                    isRegistering: false,
                                    isRegistered: false,
                                    onRegister: () {
                                      context.read<ClassBloc>().add(JoinClassEvent(classItem.id ?? ''));
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        );
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
  }
}