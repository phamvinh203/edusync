import 'package:edusync/screens/profile/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_event.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/screens/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // Khi chuyển sang unauthenticated thì quay về màn hình đăng nhập
        if (authState.status == AuthStatus.unauthenticated) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state.status == UserStatus.initial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<UserBloc>().add(const UserMeRequested());
                });
              }

              if (state.status == UserStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == UserStatus.failure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.errorMessage ??
                            'Không thể tải thông tin người dùng',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed:
                            () => context.read<UserBloc>().add(
                              const UserMeRequested(),
                            ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final displayName =
                  (((state.auth?.username))?.isNotEmpty == true)
                      ? state.auth!.username
                      : ((((state.profile?.username))?.isNotEmpty == true)
                          ? state.profile!.username!
                          : 'Người dùng');
              final avatarUrl = state.profile?.avatar ?? '';
              final classText =
                  (state.profile?.userClass != null &&
                          state.profile!.userClass!.isNotEmpty)
                      ? 'Lớp ${state.profile!.userClass} • Học sinh'
                      : 'Học sinh';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap:
                                state.isUploadingAvatar
                                    ? null
                                    : () async {
                                      final picker = ImagePicker();
                                      final picked = await picker.pickImage(
                                        source: ImageSource.gallery,
                                        maxWidth: 1024,
                                        maxHeight: 1024,
                                        imageQuality: 85,
                                      );
                                      if (picked != null) {
                                        // Gửi sự kiện cập nhật avatar
                                        if (context.mounted) {
                                          context.read<UserBloc>().add(
                                            UserAvatarUpdateRequested(
                                              picked.path,
                                            ),
                                          );
                                        }
                                      }
                                    },
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                  child:
                                      avatarUrl.isEmpty
                                          ? Text(
                                            displayName.isNotEmpty
                                                ? displayName[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          )
                                          : null,
                                ),
                                if (state.isUploadingAvatar)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            classText,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  '15',
                                  'Bài tập\nhoàn thành',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  '6',
                                  'Môn học\nđang theo',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              Expanded(
                                child: _buildStatItem('8.5', 'Điểm TB\nhọc kỳ'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Menu Items
                    _buildMenuSection(context, 'Tài khoản', [
                      _buildMenuItem(
                        Icons.person_outline,
                        'Thông tin cá nhân',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserInfoScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        Icons.school_outlined,
                        'Thông tin học tập',
                        () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const StudentAcademicScreen(),
                          //   ),
                          // );
                        },
                      ),
                      _buildMenuItem(Icons.payment, 'Quản lý học phí', () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const StudentFeeManagementScreen(),
                        //   ),
                        // );
                      }),
                      _buildMenuItem(Icons.lock_outline, 'Đổi mật khẩu', () {
                        // _showChangePasswordDialog(context);
                      }),
                    ]),

                    const SizedBox(height: 16),
                    _buildMenuSection(context, 'Cài đặt', [
                      _buildMenuItem(Icons.settings_outlined, 'Cài đặt', () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const StudentSettingsScreen(),
                        //   ),
                        // );
                      }),
                      _buildMenuItem(Icons.palette_outlined, 'Giao diện', () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const ThemeSettingsScreen(),
                        //   ),
                        // );
                      }),
                      _buildMenuItem(
                        Icons.notifications_outlined,
                        'Thông báo',
                        () {
                          // _showNotificationSettings(context);
                        },
                      ),
                      _buildMenuItem(Icons.language_outlined, 'Ngôn ngữ', () {
                        // _showLanguageSettings(context);
                      }),

                      // Consumer<ThemeProvider>(
                      //   builder: (context, themeProvider, child) {
                      //     return _buildMenuItem(
                      //       themeProvider.isDarkMode
                      //           ? Icons.light_mode_outlined
                      //           : Icons.dark_mode_outlined,
                      //       'Chế độ tối',
                      //       () {},
                      //       trailing: Switch(
                      //         value: themeProvider.isDarkMode,
                      //         onChanged: (value) => themeProvider.toggleTheme(),
                      //         activeColor: Theme.of(context).colorScheme.primary,
                      //       ),
                      //     );
                      //   },
                      // ),
                    ]),

                    const SizedBox(height: 16),
                    _buildMenuSection(context, 'Hỗ trợ', [
                      _buildMenuItem(Icons.help_outline, 'Hỗ trợ', () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const StudentSupportScreen(),
                        //   ),
                        // );
                      }),
                      _buildMenuItem(Icons.info_outline, 'Về ứng dụng', () {
                        // _showAppInfo(context);
                      }),
                      _buildMenuItem(Icons.feedback_outlined, 'Phản hồi', () {
                        // _showFeedbackDialog(context);
                      }),
                    ]),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Xác nhận trước khi đăng xuất
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Đăng xuất'),
                                  content: const Text(
                                    'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(false),
                                      child: const Text('Huỷ'),
                                    ),
                                    FilledButton(
                                      onPressed:
                                          () => Navigator.of(ctx).pop(true),
                                      child: const Text('Đăng xuất'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true && context.mounted) {
                            // Gửi sự kiện logout tới AuthBloc
                            context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red[600]),
                            const SizedBox(width: 8),
                            Text(
                              'Đăng xuất',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground.withOpacity(0.8),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
          onTap: onTap,
        );
      },
    );
  }
}
