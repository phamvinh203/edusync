import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edusync/screens/auth/login_screen.dart';
import 'package:edusync/screens/auth/register_screen.dart';

// Nhóm smoke test đơn giản cho 2 màn hình auth
void main() {
  group('Auth UI smoke', () {
    testWidgets('LoginScreen renders core widgets', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Chào mừng trở lại'), findsOneWidget);
      // Form labels
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      // Actions
      expect(find.text('Đăng nhập'), findsWidgets);
      expect(find.text('Quên mật khẩu?'), findsOneWidget);
      expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
    });

    testWidgets('Navigate from LoginScreen to SignupScreen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();

      // Nhấn "Đăng ký"
      final signUpFinder = find.text('Đăng ký');
      // Cuộn cho tới khi thấy nút/label Đăng ký nếu bị khuất
      await tester.scrollUntilVisible(
        signUpFinder,
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(signUpFinder);
      await tester.pumpAndSettle();

  // Đã thấy màn đăng ký
  expect(find.byType(SignupScreen), findsOneWidget);
  expect(find.text('Tạo tài khoản'), findsWidgets);
    });

    testWidgets('SignupScreen renders core widgets', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
      await tester.pumpAndSettle();

      // Có tiêu đề và nút cùng text "Tạo tài khoản"
      expect(find.text('Tạo tài khoản'), findsWidgets);
      expect(find.text('Tham gia EduSync ngay hôm nay'), findsOneWidget);
      expect(find.text('Họ và tên'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mật khẩu'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
      expect(find.text('Tạo tài khoản'), findsWidgets);
      expect(find.text('Đăng nhập'), findsOneWidget);
    });
  });
}
