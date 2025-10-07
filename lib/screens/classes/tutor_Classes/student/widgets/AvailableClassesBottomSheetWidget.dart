// // Widget hiển thị bottom sheet danh sách lớp học có sẵn
// import 'package:edusync/screens/classes/tutor_Classes/available_class_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:edusync/models/class_model.dart';
// import 'package:edusync/repositories/class_repository.dart';
// import 'package:edusync/blocs/class/class_bloc.dart';
// import 'package:edusync/blocs/class/class_state.dart';
// import 'package:edusync/blocs/class/class_event.dart';
// import 'package:edusync/screens/classes/tutor_Classes/student/widgets/show_register_dialog.dart';
//
// class AvailableClassesBottomSheet extends StatefulWidget {
//   final List<ClassModel> classes;
//
//   const AvailableClassesBottomSheet({super.key, required this.classes});
//
//   @override
//   State<AvailableClassesBottomSheet> createState() =>
//       _AvailableClassesBottomSheetState();
// }
//
// class _AvailableClassesBottomSheetState
//     extends State<AvailableClassesBottomSheet> {
//   // Danh sách lựa chọn grade lấy từ DB
//   List<String> _gradeOptions = [];
//   String? _selectedGrade; // Lọc theo lớp theo đúng giá trị trong DB
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       builder: (BuildContext context, ScrollController scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.search, color: Colors.blue),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Danh sách lớp gia sư',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     // Dropdown chọn lớp (gradeLevel) lấy từ DB
//                     DropdownButton<String?>(
//                       value: _selectedGrade,
//                       hint: const Text('Lọc theo lớp'),
//                       items: [
//                         const DropdownMenuItem<String?>(
//                           value: null,
//                           child: Text('Tất cả lớp'),
//                         ),
//                         ..._gradeOptions.map(
//                           (g) => DropdownMenuItem<String?>(
//                             value: g,
//                             child: Text(g),
//                           ),
//                         ),
//                       ],
//                       onChanged: (val) {
//                         setState(() {
//                           _selectedGrade = val;
//                         });
//                       },
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: FutureBuilder<List<ClassModel>>(
//                   future: ClassRepository().getAllClasses(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(
//                                 Icons.error_outline,
//                                 color: Colors.redAccent,
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Không thể tải danh sách lớp: ${snapshot.error}',
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//
//                     final allClasses = snapshot.data ?? [];
//                     final availableClasses =
//                         allClasses.where((classItem) {
//                           final currentStudents = classItem.students.length;
//                           final maxStudents = classItem.maxStudents ?? 0;
//                           return currentStudents < maxStudents;
//                         }).toList();
//
//                     // Cập nhật danh sách grade options từ DB (độc nhất)
//                     final newOptions =
//                         availableClasses
//                             .map((c) => (c.gradeLevel ?? '').trim())
//                             .where((s) => s.isNotEmpty)
//                             .toSet()
//                             .toList()
//                           ..sort();
//                     if (newOptions.join('|') != _gradeOptions.join('|')) {
//                       // Cập nhật sau frame để tránh setState trong build của FutureBuilder
//                       WidgetsBinding.instance.addPostFrameCallback((_) {
//                         if (mounted) {
//                           setState(() {
//                             _gradeOptions = newOptions;
//                             // Nếu giá trị đang chọn không còn trong options thì reset về null
//                             if (_selectedGrade != null &&
//                                 !_gradeOptions.contains(_selectedGrade)) {
//                               _selectedGrade = null;
//                             }
//                           });
//                         }
//                       });
//                     }
//
//                     // Lọc theo gradeLevel nếu chọn (đúng theo chuỗi từ DB)
//                     List<ClassModel> filtered = availableClasses;
//                     if (_selectedGrade != null) {
//                       filtered =
//                           availableClasses
//                               .where(
//                                 (c) =>
//                                     (c.gradeLevel ?? '').trim() ==
//                                     _selectedGrade,
//                               )
//                               .toList();
//                     }
//
//                     if (filtered.isEmpty) {
//                       return const Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.school_outlined,
//                               size: 64,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(height: 16),
//                             Text(
//                               'Hiện tại chưa có lớp gia sư nào',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//
//                     return ListView.builder(
//                       controller: scrollController,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: filtered.length,
//                       itemBuilder: (context, index) {
//                         final classItem = filtered[index];
//                         return AvailableClassCard(
//                           classItem: classItem,
//                           onRegister: (classItem, color) {
//                             showDialog(
//                               context: context,
//                               builder: (dialogContext) {
//                                 return BlocListener<ClassBloc, ClassState>(
//                                   listener: (context, state) {
//                                     if (state is ClassJoinSuccess) {
//                                       Navigator.pop(dialogContext);
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         const SnackBar(
//                                           content: Text(
//                                             'Đăng ký lớp thành công! Vui lòng chờ giáo viên duyệt.',
//                                           ),
//                                           backgroundColor: Colors.green,
//                                           duration: Duration(seconds: 4),
//                                         ),
//                                       );
//                                     } else if (state is ClassError ||
//                                         state is ClassJoinError) {
//                                       Navigator.pop(dialogContext);
//                                       ScaffoldMessenger.of(
//                                         context,
//                                       ).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             'Lỗi: ${state is ClassError ? state.message : (state as ClassJoinError).message}',
//                                           ),
//                                           backgroundColor: Colors.red,
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: RegisterClassDialog(
//                                     classItem: classItem,
//                                     subjectColor: color,
//                                     isRegistering: false,
//                                     isRegistered: false,
//                                     onRegister: () {
//                                       context.read<ClassBloc>().add(
//                                         JoinClassEvent(classItem.id ?? ''),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// lib/screens/classes/tutor_Classes/student/available_classes_bottomsheet.dart
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/show_register_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_bloc.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_event.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_state.dart';
import 'package:edusync/screens/classes/tutor_Classes/available_class_card.dart';

class AvailableClassesBottomSheet extends StatefulWidget {
  const AvailableClassesBottomSheet({super.key});

  @override
  State<AvailableClassesBottomSheet> createState() =>
      _AvailableClassesBottomSheetState();
}

class _AvailableClassesBottomSheetState
    extends State<AvailableClassesBottomSheet> {
  List<String> _gradeOptions = [];
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    // Luôn refresh dữ liệu mới khi mở bottom sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AvailableClassesBloc>().add(
          RefreshAvailableClassesEvent(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header (giữ nguyên)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Danh sách lớp gia sư',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String?>(
                      value: _selectedGrade,
                      hint: const Text('Lọc theo lớp'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tất cả lớp'),
                        ),
                        ..._gradeOptions.map(
                          (g) => DropdownMenuItem<String?>(
                            value: g,
                            child: Text(g),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedGrade = val;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // Body: dùng BlocBuilder
              Expanded(
                child: BlocBuilder<AvailableClassesBloc, AvailableClassesState>(
                  builder: (context, state) {
                    if (state is AvailableClassesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is AvailableClassesLoaded) {
                      final all = state.classes;
                      // compute grade options
                      final newOptions =
                          all
                              .map((c) => (c.gradeLevel ?? '').trim())
                              .where((s) => s.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort();
                      if (newOptions.join('|') != _gradeOptions.join('|')) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _gradeOptions = newOptions;
                              if (_selectedGrade != null &&
                                  !_gradeOptions.contains(_selectedGrade)) {
                                _selectedGrade = null;
                              }
                            });
                          }
                        });
                      }

                      // filter by grade
                      var filtered = all;
                      if (_selectedGrade != null) {
                        filtered =
                            all
                                .where(
                                  (c) =>
                                      (c.gradeLevel ?? '').trim() ==
                                      _selectedGrade,
                                )
                                .toList();
                      }

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Hiện tại chưa có lớp gia sư nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final classItem = filtered[index];
                          final status =
                              state.registrationStatus[classItem.id ?? ''] ??
                              RegistrationStatus.idle;

                          return AvailableClassCard(
                            classItem: classItem,
                            registrationStatus: status,
                            onRegister: (classId) {
                              // mở dialog và đăng ký khi xác nhận
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  return BlocListener<
                                    AvailableClassesBloc,
                                    AvailableClassesState
                                  >(
                                    listenWhen: (prev, next) {
                                      // listen khi registration status thay đổi cho chính classId
                                      RegistrationStatus? p;
                                      RegistrationStatus? n;
                                      if (prev is AvailableClassesLoaded) {
                                        p = prev.registrationStatus[classId];
                                      }
                                      if (next is AvailableClassesLoaded) {
                                        n = next.registrationStatus[classId];
                                      }
                                      return p != n;
                                    },
                                    listener: (context, nextState) {
                                      if (nextState is AvailableClassesLoaded) {
                                        final st =
                                            nextState
                                                .registrationStatus[classId];
                                        if (st == RegistrationStatus.pending ||
                                            st ==
                                                RegistrationStatus.registered) {
                                          Navigator.pop(
                                            dialogContext,
                                          ); // đóng dialog
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Đăng ký lớp thành công! Vui lòng chờ giáo viên duyệt.',
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        } else if (st ==
                                            RegistrationStatus.failed) {
                                          Navigator.pop(dialogContext);
                                          final err =
                                              nextState
                                                  .errorMessages[classId] ??
                                              'Lỗi khi đăng ký';
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Lỗi: $err'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: RegisterClassDialog(
                                      classItem: classItem,
                                      subjectColor: _getSubjectColor(
                                        classItem.subject,
                                      ),
                                      isRegistering:
                                          status ==
                                          RegistrationStatus.registering,
                                      isRegistered:
                                          status ==
                                              RegistrationStatus.registered ||
                                          status == RegistrationStatus.pending,
                                      onRegister: () {
                                        context
                                            .read<AvailableClassesBloc>()
                                            .add(
                                              RegisterClassRequested(
                                                classItem.id ?? '',
                                              ),
                                            );
                                      },
                                      onCancel: () {
                                        context
                                            .read<AvailableClassesBloc>()
                                            .add(
                                              CancelRegisterClassRequested(
                                                classItem.id ?? '',
                                              ),
                                            );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    }

                    // fallback
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // copy-paste helper color fn from your AvailableClassCard (or import)
  Color _getSubjectColor(String subject) {
    switch (subject.toLowerCase()) {
      case 'toán':
      case 'math':
        return Colors.blue;
      case 'vật lý':
      case 'physics':
        return Colors.purple;
      case 'hóa học':
      case 'chemistry':
        return Colors.green;
      case 'sinh học':
      case 'biology':
        return Colors.teal;
      case 'tiếng anh':
      case 'english':
        return Colors.orange;
      case 'văn học':
      case 'literature':
        return Colors.red;
      case 'lịch sử':
      case 'history':
        return Colors.brown;
      case 'địa lý':
      case 'geography':
        return Colors.cyan;
      default:
        return Colors.indigo;
    }
  }
}
