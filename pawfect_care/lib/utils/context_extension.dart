import 'package:flutter/material.dart';

enum SnackBarTheme { success, error, info }

extension ContextExtension on BuildContext {
  void showSnackBar(
    String message, {
    SnackBarTheme theme = SnackBarTheme.info,
  }) {
    Color? backgroundColor;
    switch (theme) {
      case SnackBarTheme.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarTheme.error:
        backgroundColor = Theme.of(this).colorScheme.error;
        break;
      case SnackBarTheme.info:
        backgroundColor = Theme.of(this).snackBarTheme.backgroundColor;
        break;
    }

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}
