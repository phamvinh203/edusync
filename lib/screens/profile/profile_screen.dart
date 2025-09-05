import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';

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
                (state.auth?.username.isNotEmpty == true)
                    ? state.auth!.username
                    : ((state.profile?.username?.isNotEmpty == true)
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
                          ).colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
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
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                  : null,
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
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
                              color: Colors.white.withOpacity(0.3),
                            ),
                            Expanded(
                              child: _buildStatItem('6', 'Môn học\nđang theo'),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.3),
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
