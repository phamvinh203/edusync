import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:edusync/screens/home/home_screen.dart';
import 'package:edusync/screens/classes/class_screen.dart';
import 'package:edusync/screens/exercises/exercis_screen.dart';
import 'package:edusync/screens/profile/profile_screen.dart';
import 'package:edusync/blocs/auth/auth_bloc.dart';
import 'package:edusync/blocs/auth/auth_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final userRole = authState.user?.role ?? '';
        final isTeacher = userRole.toLowerCase() == 'teacher';

        // Danh sách các màn hình cho các tab
        final List<Widget> pages = [
          const HomeScreen(),
          const ClassScreen(),
          ExercisScreen(isTeacher: isTeacher),
          const ProfileScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 8,
                ),
                child: GNav(
                  rippleColor: primaryColor[300]!,
                  hoverColor: primaryColor[100]!,
                  gap: 6,
                  activeColor: Colors.white,
                  iconSize: 22,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: primaryColor[600]!,
                  color: Colors.grey[600],
                  tabs: const [
                    GButton(icon: Icons.home_rounded, text: 'Trang chủ'),
                    GButton(icon: Icons.class_, text: 'Lớp học'),
                    GButton(icon: Icons.assignment_rounded, text: 'Bài tập'),
                    GButton(icon: Icons.person_rounded, text: 'Cá nhân'),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
