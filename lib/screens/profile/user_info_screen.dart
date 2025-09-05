import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/screens/widgets/labeled_text_field.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _classCtrl;
  late final TextEditingController _addressCtrl;
  DateTime? _dob;
  String? _gender; // male|female|other

  @override
  void initState() {
    super.initState();
    final state = context.read<UserBloc>().state;
    _usernameCtrl = TextEditingController(
      text: state.profile?.username?.isNotEmpty == true
          ? state.profile!.username
          : state.auth?.username ?? '',
    );
    _emailCtrl = TextEditingController(
      text: state.profile?.email?.isNotEmpty == true
          ? state.profile!.email
          : state.auth?.email ?? '',
    );
    _phoneCtrl = TextEditingController(text: state.profile?.phone ?? '');
    _classCtrl = TextEditingController(text: state.profile?.studentClass ?? '');
    _addressCtrl = TextEditingController(text: state.profile?.address ?? '');
    _dob = state.profile?.dateOfBirth;
    _gender = state.profile?.gender;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _classCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listenWhen: (p, c) => p.successMessage != c.successMessage || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if ((state.successMessage ?? '').isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
        }
        if ((state.errorMessage ?? '').isNotEmpty && !state.isUploadingAvatar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (state.status == UserStatus.initial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<UserBloc>().add(const UserMeRequested());
            }
          });
        }
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Thông tin cá nhân'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledTextField(
                      label: 'Tên hiển thị',
                      controller: _usernameCtrl,
                      hintText: 'Nhập tên',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập tên'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'Email',
                      controller: _emailCtrl,
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                        final emailRegex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                        if (!emailRegex.hasMatch(v.trim())) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'Số điện thoại',
                      controller: _phoneCtrl,
                      hintText: 'VD: 0912345678',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'Lớp',
                      controller: _classCtrl,
                      hintText: 'VD: 12A1',
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 12),
                    LabeledTextField(
                      label: 'Địa chỉ',
                      controller: _addressCtrl,
                      hintText: 'Số nhà, đường, ...',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Ngày sinh
                    Text('Ngày sinh', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4776E6))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: state.isUpdatingProfile
                          ? null
                          : () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dob ?? DateTime(now.year - 10, now.month, now.day),
                                firstDate: DateTime(1900),
                                lastDate: DateTime(now.year, now.month, now.day),
                              );
                              if (picked != null) {
                                setState(() => _dob = picked);
                              }
                            },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          prefixIcon: const Icon(Icons.cake_outlined, color: Color(0xFF8E54E9)),
                        ),
                        child: Text(
                          _dob != null
                              ? _dob!.toLocal().toString().split(' ').first
                              : 'Chọn ngày sinh',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Giới tính
                    Text('Giới tính', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF4776E6))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _gender?.isNotEmpty == true ? _gender : null,
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Nam')),
                        DropdownMenuItem(value: 'female', child: Text('Nữ')),
                        DropdownMenuItem(value: 'other', child: Text('Khác')),
                      ],
                      onChanged: state.isUpdatingProfile ? null : (v) => setState(() => _gender = v),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        prefixIcon: const Icon(Icons.wc_outlined, color: Color(0xFF8E54E9)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: state.isUpdatingProfile
                            ? null
                            : () {
                                if (_formKey.currentState?.validate() != true) return;
                                context.read<UserBloc>().add(
                                  UserUpdateProfileRequested(
                                    username: _usernameCtrl.text.trim(),
                                    email: _emailCtrl.text.trim(),
                                    phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
                                    studentClass: _classCtrl.text.trim().isNotEmpty ? _classCtrl.text.trim() : null,
                                    address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
                                    dateOfBirth: _dob,
                                    gender: _gender,
                                  ),
                                );
                              },
                        icon: state.isUpdatingProfile
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(state.isUpdatingProfile ? 'Đang lưu...' : 'Lưu thông tin'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}