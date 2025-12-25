import 'package:edusync/models/class_model.dart';

/// Helper class để format và xử lý thông tin lớp học
class ClassInfoHelper {
  /// Format currency với dấu phân cách hàng nghìn
  static String formatCurrency(double amount) {
    if (amount == amount.toInt()) {
      return _addThousandsSeparator(amount.toInt().toString());
    } else {
      return _addThousandsSeparator(amount.toString());
    }
  }

  static String _addThousandsSeparator(String number) {
    List<String> parts = number.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    String result = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        result += '.';
      }
      result += integerPart[i];
    }
    return result + decimalPart;
  }

  /// Lấy text hiển thị số học sinh
  static String getStudentCountText(ClassModel classItem) {
    final currentStudents = classItem.students.length;
    final maxStudents = classItem.maxStudents ?? 0;
    return '$currentStudents/$maxStudents';
  }

  /// Kiểm tra lớp có còn chỗ không
  static bool isClassOpen(ClassModel classItem) {
    final currentStudents = classItem.students.length;
    final maxStudents = classItem.maxStudents ?? 0;
    return currentStudents < maxStudents;
  }

  /// Lấy text hiển thị giá/buổi
  static String getPriceText(ClassModel classItem) {
    if (classItem.pricePerSession != null) {
      return '${formatCurrency(classItem.pricePerSession!)} VNĐ';
    }
    return 'Miễn phí';
  }

  /// Lấy text hiển thị trạng thái lớp
  static String getClassStatusText(ClassModel classItem) {
    return isClassOpen(classItem) ? 'Đang mở' : 'Đã đầy';
  }

  /// Kiểm tra user đã tham gia lớp chưa
  static bool isUserJoined(ClassModel classItem, String userId) {
    return userId.isNotEmpty && classItem.students.contains(userId);
  }

  /// Kiểm tra user đang trong danh sách chờ
  static bool isUserPending(ClassModel classItem, String userId) {
    return userId.isNotEmpty && classItem.pendingStudents.contains(userId);
  }
}
