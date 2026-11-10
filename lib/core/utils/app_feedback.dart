import 'package:flutter/material.dart';

class AppFeedback {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.check_circle_outline_rounded,
      isSuccess: true,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.error_outline_rounded,
      isError: true,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.warning_amber_rounded,
      isWarning: true,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      iconData: Icons.info_outline_rounded,
    );
  }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required IconData iconData,
    bool isSuccess = false,
    bool isError = false,
    bool isWarning = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bg;
    Color fg;
    Color iconColor;

    if (isError) {
      bg = colorScheme.errorContainer;
      fg = colorScheme.onErrorContainer;
      iconColor = colorScheme.error;
    } else if (isSuccess) {
      bg = colorScheme.surfaceContainerHighest;
      fg = colorScheme.onSurface;
      iconColor = colorScheme.primary;
    } else if (isWarning) {
      bg = colorScheme.surfaceContainerHighest;
      fg = colorScheme.onSurface;
      iconColor = colorScheme.tertiary;
    } else {
      bg = colorScheme.surfaceContainerHigh;
      fg = colorScheme.onSurface;
      iconColor = colorScheme.secondary;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        backgroundColor: bg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        content: Row(
          children: [
            Icon(iconData, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
