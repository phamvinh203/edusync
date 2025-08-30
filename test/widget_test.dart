import 'package:flutter_test/flutter_test.dart';
import 'package:edusync/main.dart';

void main() {
  testWidgets('MyApp shows LoginScreen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Chào mừng trở lại'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets); // button + possible texts
  });
}
