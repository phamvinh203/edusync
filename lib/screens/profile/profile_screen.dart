import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                (state.profile?.studentClass != null &&
                        state.profile!.studentClass!.isNotEmpty)
                    ? 'Lớp ${state.profile!.studentClass} • Học sinh'
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
                                  color: Theme.of(context).colorScheme.primary,
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
                              child: _buildStatItem('6', 'Môn học\nđang theo'),
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
                ],
              ),
            );
          },
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
}
