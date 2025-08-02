import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ErrorHandler {
  static void showErrorSnackBar(BuildContext context, String message, {String? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        action: action != null ? SnackBarAction(
          label: action,
          textColor: Colors.white,
          onPressed: () {},
        ) : null,
      ),
    );
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  static String getFirebaseErrorMessage(dynamic error) {
    final String errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('network')) {
      return 'Network connection problem. Please check your internet and try again.';
    } else if (errorMessage.contains('user-not-found')) {
      return 'Account not found. Please check your credentials or create a new account.';
    } else if (errorMessage.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (errorMessage.contains('email-already-in-use')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (errorMessage.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (errorMessage.contains('invalid-email')) {
      return 'Invalid email address format.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
