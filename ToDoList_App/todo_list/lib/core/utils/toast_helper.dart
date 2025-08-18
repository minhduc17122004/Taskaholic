import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// ToastHelper - Lớp tiện ích để hiển thị toast notifications
/// Cung cấp các phương thức để hiển thị toast với styling nhất quán
class ToastHelper {
  static final Map<String, ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> _loadingToasts = {};

  /// Hiển thị toast loading khi đang xử lý tác vụ
  static void showLoadingToast(BuildContext context, String message, {String? key}) {
    // Hủy toast loading cũ nếu có
    if (key != null && _loadingToasts.containsKey(key)) {
      _loadingToasts[key]!.close();
      _loadingToasts.remove(key);
    }

    final controller = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary.withOpacity(0.9),
        duration: const Duration(seconds: 30), // Tăng thời gian để có thể hủy thủ công
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Lưu controller để có thể hủy sau
    if (key != null) {
      _loadingToasts[key] = controller;
    }
  }

  /// Hiển thị toast thành công
  static void showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Hiển thị toast lỗi
  static void showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Hiển thị toast cảnh báo
  static void showWarningToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Hiển thị toast thông tin
  static void showInfoToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Hiển thị toast xác nhận xóa với action buttons
  static void showDeleteConfirmationToast(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
    VoidCallback onCancel,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onCancel();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 1, 63, 113),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Hủy toast loading cụ thể
  static void cancelLoadingToast(String key) {
    if (_loadingToasts.containsKey(key)) {
      _loadingToasts[key]!.close();
      _loadingToasts.remove(key);
    }
  }

  /// Hủy tất cả toast loading
  static void cancelAllLoadingToasts() {
    for (final controller in _loadingToasts.values) {
      controller.close();
    }
    _loadingToasts.clear();
  }

  /// Hủy tất cả toast đang hiển thị
  static void cancelAllToasts(BuildContext context) {
    // Hủy tất cả loading toasts
    cancelAllLoadingToasts();
    // Hủy toast hiện tại
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Ví dụ sử dụng trong ứng dụng:
  /// 
  /// ```dart
  /// // Hiển thị toast loading với key để có thể hủy sau
  /// ToastHelper.showLoadingToast(context, 'Đang tải dữ liệu...', key: 'loading_key');
  /// 
  /// // Hủy toast loading cụ thể
  /// ToastHelper.cancelLoadingToast('loading_key');
  /// 
  /// // Hủy tất cả toast loading
  /// ToastHelper.cancelAllLoadingToasts();
  /// 
  /// // Hiển thị toast thành công
  /// ToastHelper.showSuccessToast(context, 'Đã lưu thành công!');
  /// 
  /// // Hiển thị toast xác nhận xóa
  /// ToastHelper.showDeleteConfirmationToast(
  ///   context,
  ///   'Bạn có chắc muốn xóa nhiệm vụ này?',
  ///   () => deleteTask(),
  ///   () => ToastHelper.cancelAllToasts(context),
  /// );
  /// 
  /// // Hủy tất cả toast
  /// ToastHelper.cancelAllToasts(context);
  /// ```
}
