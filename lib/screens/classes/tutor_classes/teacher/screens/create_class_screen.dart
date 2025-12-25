import 'package:edusync/utils/day_of_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edusync/models/class_model.dart';
import 'package:edusync/repositories/class_repository.dart';
import 'package:edusync/core/services/notification_service.dart';
import 'package:edusync/l10n/app_localizations.dart';

// Custom formatter cho số tiền
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ tất cả ký tự không phải số
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format với dấu chấm phân cách hàng nghìn
    String formatted = _addThousandsSeparator(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandsSeparator(String number) {
    String result = '';
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        result += '.';
      }
      result += number[i];
    }
    return result;
  }
}

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxStudentsController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _pricePerSessionController = TextEditingController();

  final ClassRepository _classRepository = ClassRepository();

  List<Schedule> _schedules = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxStudentsController.dispose();
    _gradeLevelController.dispose();
    _pricePerSessionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createNewClass),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thông tin cơ bản
                _buildSectionTitle(AppLocalizations.of(context)!.basicInfo),
                const SizedBox(height: 16),

                // Tên lớp học
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.classNameRequired,
                    hintText: AppLocalizations.of(context)!.enterClassName,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.class_),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterClassName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Môn học
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.subjectRequired,
                    hintText: AppLocalizations.of(context)!.enterSubject,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.book),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterSubject;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Lớp dạy thêm
                TextFormField(
                  controller: _gradeLevelController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.extraClass,
                    hintText: AppLocalizations.of(context)!.extraClassHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.grade),
                  ),
                ),
                const SizedBox(height: 16),

                // Giá tiền cho 1 buổi học
                TextFormField(
                  controller: _pricePerSessionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.pricePerSession,
                    hintText: AppLocalizations.of(context)!.priceHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monetization_on),
                    suffixText: 'VNĐ',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Loại bỏ dấu chấm để kiểm tra số
                      final cleanValue = value.replaceAll('.', '');
                      final number = double.tryParse(cleanValue);
                      if (number == null || number <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.pleaseEnterValidPrice;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mô tả
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    hintText: AppLocalizations.of(context)!.descriptionHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),

                // Địa điểm
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.locationLabel,
                    hintText: AppLocalizations.of(context)!.locationHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),

                // Số học viên tối đa
                TextFormField(
                  controller: _maxStudentsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.maxStudents,
                    hintText: AppLocalizations.of(context)!.maxStudentsHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = int.tryParse(value);
                      if (number == null || number <= 0) {
                        return AppLocalizations.of(
                          context,
                        )!.pleaseEnterValidNumber;
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Lịch học
                _buildSectionTitle(AppLocalizations.of(context)!.schedule),
                const SizedBox(height: 16),

                ..._schedules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final schedule = entry.value;
                  return _buildScheduleCard(context, schedule, index);
                }),

                // Nút thêm lịch học
                OutlinedButton.icon(
                  onPressed: _addSchedule,
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.addSchedule),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                    side: BorderSide(color: Colors.blue[600]!),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),

                const SizedBox(height: 32),

                // Nút tạo lớp học
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createClass,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              AppLocalizations.of(context)!.createClassButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    Schedule schedule,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.scheduleNumber(index + 1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeSchedule(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                context,
              )!.dayLabel(getVietnameseDayOfWeek(schedule.dayOfWeek)),
            ),
            Text(
              AppLocalizations.of(
                context,
              )!.classTimeLabel(schedule.startTime, schedule.endTime),
            ),
          ],
        ),
      ),
    );
  }

  void _addSchedule() {
    showDialog(
      context: context,
      builder:
          (context) => _ScheduleDialog(
            onSave: (schedule) {
              setState(() {
                _schedules.add(schedule);
              });
            },
          ),
    );
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final maxStudents =
          _maxStudentsController.text.trim().isEmpty
              ? null
              : int.tryParse(_maxStudentsController.text.trim());

      final gradeLevel =
          _gradeLevelController.text.trim().isEmpty
              ? null
              : _gradeLevelController.text.trim();

      final pricePerSession =
          _pricePerSessionController.text.trim().isEmpty
              ? null
              : double.tryParse(
                _pricePerSessionController.text.trim().replaceAll('.', ''),
              );

      final response = await _classRepository.createClass(
        nameClass: _nameController.text.trim(),
        subject: _subjectController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        schedule: _schedules,
        location:
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
        maxStudents: maxStudents,
        gradeLevel: gradeLevel,
        pricePerSession: pricePerSession,
      );

      if (mounted) {
        // Fire local notification for teacher on successful class creation
        try {
          await NotificationService().showClassCreatedNotification(
            className: _nameController.text.trim(),
            subject: _subjectController.text.trim(),
          );
        } catch (_) {
          // Ignore notification failures to not block UX
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.createClassSuccess),
            backgroundColor: Colors.green,
          ),
        );
        // Trả về ClassModel để cập nhật danh sách
        Navigator.of(context).pop(response.data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.errorPrefix}: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Dialog để thêm lịch học
class _ScheduleDialog extends StatefulWidget {
  final Function(Schedule) onSave;

  const _ScheduleDialog({required this.onSave});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  String _selectedDay = 'Monday';
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addScheduleDialog),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chọn thứ
          DropdownButtonFormField<String>(
            value: _selectedDay,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.dayLabel(''),
              border: const OutlineInputBorder(),
            ),
            items:
                [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday',
                ].map((d) {
                  return DropdownMenuItem<String>(
                    value: d,
                    child: Text(getVietnameseDayOfWeek(d)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDay = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Giờ bắt đầu
          ListTile(
            title: Text(AppLocalizations.of(context)!.startTime),
            subtitle: Text(_startTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() {
                  _startTime = time;
                });
              }
            },
          ),

          // Giờ kết thúc
          ListTile(
            title: Text(AppLocalizations.of(context)!.endTime),
            subtitle: Text(_endTime.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() {
                  _endTime = time;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_endTime.hour < _startTime.hour ||
                (_endTime.hour == _startTime.hour &&
                    _endTime.minute <= _startTime.minute)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.endTimeMustBeAfterStart,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final schedule = Schedule(
              dayOfWeek: _selectedDay,
              startTime:
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
              endTime:
                  '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
            );

            widget.onSave(schedule);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
