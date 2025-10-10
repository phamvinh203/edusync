import 'package:edusync/screens/classes/tutor_classes/shared/widgets/cards/available_class_card.dart';
import 'package:edusync/screens/classes/tutor_classes/student/widgets/dialogs/show_register_dialog.dart';
import 'package:edusync/utils/style_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_bloc.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_event.dart';
import 'package:edusync/blocs/AvailableClasses/availableClasses_state.dart';
import 'package:edusync/l10n/app_localizations.dart';

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
                    Text(
                      AppLocalizations.of(context)!.availableTutorClasses,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    DropdownButton<String?>(
                      value: _selectedGrade,
                      hint: Text(AppLocalizations.of(context)!.filterByGrade),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(AppLocalizations.of(context)!.allGrades),
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
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.school_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.noTutorClassesAvailable,
                                style: const TextStyle(
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
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.registerSuccess,
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            ),
                                          );
                                        } else if (st ==
                                            RegistrationStatus.failed) {
                                          Navigator.pop(dialogContext);
                                          final err =
                                              nextState
                                                  .errorMessages[classId] ??
                                              AppLocalizations.of(
                                                context,
                                              )!.registerError;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${AppLocalizations.of(context)!.errorPrefix}: $err',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: RegisterClassDialog(
                                      classItem: classItem,
                                      subjectColor: getSubjectColor(
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
}
