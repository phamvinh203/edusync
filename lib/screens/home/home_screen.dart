import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';
import 'package:edusync/blocs/auth/auth_event.dart';
import 'package:edusync/screens/auth/login_screen.dart';
import 'package:edusync/screens/bottom_nav.dart';
import 'package:edusync/blocs/home_nav/home_nav_bloc.dart';
import 'package:edusync/screens/classes/class_scren.dart';
import 'package:edusync/screens/exercises/exercis_screen.dart';
import 'package:edusync/screens/profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeWelcome(username: username),
      const ClassScreen(),
      const ExercisScreen(),
      const ProfileScreen(),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocProvider(
        create: (_) => HomeNavBloc(),
        child: BlocBuilder<HomeNavBloc, HomeNavState>(
          builder: (context, navState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('EduSync'),
                actions: [
                  IconButton(
                    tooltip: 'Đăng xuất',
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              body: IndexedStack(
                index: navState.currentIndex,
                children: pages,
              ),
              bottomNavigationBar: BottomNavBar(
                selectedIndex: navState.currentIndex,
                onItemTapped: (i) =>
                    context.read<HomeNavBloc>().add(HomeTabSelected(i)),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Trang chào mừng trong tab Trang chủ
class _HomeWelcome extends StatelessWidget {
  final String username;
  const _HomeWelcome({required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, size: 64, color: Color(0xFF4776E6)),
          const SizedBox(height: 16),
          Text(
            'Xin chào, $username',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn đã đăng nhập thành công!',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
