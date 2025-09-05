import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/user/user_bloc.dart';
import 'package:edusync/blocs/user/user_event.dart';
import 'package:edusync/blocs/user/user_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi load /users/me khi vào màn hình
    context.read<UserBloc>().add(const UserMeRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  final theme = Theme.of(context).textTheme;

                  if (state.status == UserStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == UserStatus.failure) {
                    return Text(
                      state.errorMessage ?? 'Lỗi tải thông tin người dùng',
                      style: theme.bodyMedium?.copyWith(color: Colors.red),
                    );
                  }

                  final username =
                      state.auth?.username ??
                      state.profile?.username ??
                      'Người dùng';
                  final avatarUrl = state.profile?.avatar;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào!',
                            style: theme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            username,
                            style: theme.titleMedium?.copyWith(
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue[100],
                        backgroundImage:
                            (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl)
                                : null,
                        child:
                            (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(
                                  (username.isNotEmpty ? username[0] : 'U')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                : null,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
