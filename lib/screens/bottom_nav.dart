import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// Thanh điều hướng dưới sử dụng google_nav_bar.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: GNav(
            gap: 6,
            rippleColor: cs.primary.withOpacity(0.12),
            hoverColor: cs.primary.withOpacity(0.08),
            color: cs.onSurfaceVariant,
            activeColor: cs.primary,
            tabBackgroundColor: cs.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            selectedIndex: selectedIndex,
            onTabChange: onItemTapped,
            tabs: const [
              GButton(icon: Icons.home_rounded, text: 'Trang chủ'),
              GButton(icon: Icons.class_, text: 'Lớp học'),
              GButton(icon: Icons.assignment_rounded, text: 'Bài tập'),
              GButton(icon: Icons.person_rounded, text: 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }
}