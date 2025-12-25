// Widget hiển thị bottom sheet danh sách lớp học có sẵn
import 'package:edusync/screens/classes/tutor_Classes/available_class_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/blocs/available_classes/available_classes_bloc.dart';
import 'package:edusync/blocs/available_classes/available_classes_state.dart';
import 'package:edusync/blocs/available_classes/available_classes_event.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_bloc.dart';
import 'package:edusync/blocs/registered_classes/registered_classes_event.dart';
import 'package:edusync/screens/classes/tutor_Classes/student/widgets/show_register_dialog.dart';

class AvailableClassesBottomSheet extends StatefulWidget {
  final List<ClassModel> classes;

  const AvailableClassesBottomSheet({super.key, required this.classes});

  @override
  State<AvailableClassesBottomSheet> createState() =>
      _AvailableClassesBottomSheetState();
}

class _AvailableClassesBottomSheetState
    extends State<AvailableClassesBottomSheet> {
  // Danh sách lựa chọn grade lấy từ DB
  List<String> _gradeOptions = [];
  String? _selectedGrade; // Lọc theo lớp theo đúng giá trị trong DB

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
                    // Dropdown chọn lớp (gradeLevel) lấy từ DB
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
              Expanded(
                child: BlocBuilder<AvailableClassesBloc, AvailableClassesState>(
                  builder: (context, state) {
                    // Lần đầu vào sheet -> yêu cầu load nếu chưa có
                    if (state is AvailableClassesInitial) {
                      context.read<AvailableClassesBloc>().add(
                        LoadAvailableClassesEvent(),
                      );
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AvailableClassesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AvailableClassesError) {
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
                                'Không thể tải danh sách lớp: ${state.message}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed:
                                    () => context
                                        .read<AvailableClassesBloc>()
                                        .add(LoadAvailableClassesEvent()),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state is! AvailableClassesLoaded) {
                      return const SizedBox.shrink();
                    }

                    final availableClasses = state.availableClasses;

                    // Cập nhật danh sách grade options từ data đã có trong bloc
                    final newOptions =
                        availableClasses
                            .map((c) => (c.gradeLevel ?? '').trim())
                            .where((s) => s.isNotEmpty)
                            .toSet()
                            .toList()
                          ..sort();

                    if (newOptions.join('|') != _gradeOptions.join('|')) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        setState(() {
                          _gradeOptions = newOptions;
                          if (_selectedGrade != null &&
                              !_gradeOptions.contains(_selectedGrade)) {
                            _selectedGrade = null;
                          }
                        });
                      });
                    }

                    // Lọc theo gradeLevel nếu chọn (đúng theo chuỗi từ DB)
                    List<ClassModel> filtered = availableClasses;
                    if (_selectedGrade != null) {
                      filtered =
                          availableClasses
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AvailableClassCard(
                              classItem: classItem,
                              onRegister: (classItem, color) async {
                                await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return BlocProvider.value(
                                      value:
                                          context.read<AvailableClassesBloc>(),
                                      child: BlocListener<
                                        AvailableClassesBloc,
                                        AvailableClassesState
                                      >(
                                        listener: (blocCtx, state) {
                                          if (state
                                              is ClassRegistrationSuccess) {
                                            Navigator.of(
                                              dialogContext,
                                            ).pop(true);
                                            // Sử dụng context từ BottomSheet thay vì dialogContext
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Đăng ký lớp thành công! Vui lòng chờ giáo viên duyệt.',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(
                                                    seconds: 4,
                                                  ),
                                                ),
                                              );
                                              // Refresh dữ liệu để cập nhật trạng thái
                                              context
                                                  .read<AvailableClassesBloc>()
                                                  .add(
                                                    RefreshAvailableClassesEvent(),
                                                  );
                                              // Cũng refresh RegisteredClassesBloc để cập nhật danh sách lớp đã đăng ký
                                              try {
                                                context
                                                    .read<
                                                      RegisteredClassesBloc
                                                    >()
                                                    .add(
                                                      LoadRegisteredClassesEvent(),
                                                    );
                                              } catch (e) {
                                                // Có thể RegisteredClassesBloc không available trong context này
                                                print(
                                                  'Could not refresh RegisteredClassesBloc: $e',
                                                );
                                              }
                                            }
                                          } else if (state
                                              is ClassRegistrationError) {
                                            Navigator.of(
                                              dialogContext,
                                            ).pop(false);
                                            if (mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Lỗi: ${state.message}',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: BlocBuilder<
                                          AvailableClassesBloc,
                                          AvailableClassesState
                                        >(
                                          builder: (context, currentState) {
                                            return RegisterClassDialog(
                                              classItem: classItem,
                                              subjectColor: color,
                                              isRegistering:
                                                  currentState
                                                      is RegisteringForClass,
                                              isRegistered:
                                                  false, // Sẽ được kiểm tra từ server data
                                              onRegister: () {
                                                context
                                                    .read<
                                                      AvailableClassesBloc
                                                    >()
                                                    .add(
                                                      RegisterForClassEvent(
                                                        classItem.id ?? '',
                                                      ),
                                                    );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
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
