// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomSnackbar {
  // Show a loading snackbar with circular progress indicator
  static void showLoading(BuildContext context, {String? message}) {
    // Hide any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show the new custom snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildLoadingContent(message),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 15), // Long duration for loading
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height / 2 - 40, 
          left: 30, 
          right: 30
        ),
      ),
    );
  }
  
  // Show a message snackbar (success, error, info)
  static void showMessage(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Hide any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show the new custom snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildMessageContent(message, type),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height / 2 - 40, 
          left: 30, 
          right: 30
        ),
      ),
    );
  }
  
  // Hide any visible snackbar
  static void hideSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
  
  // Build loading content with spinner
  static Widget _buildLoadingContent(String? message) {
    return Container(
      height: 150,
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (message != null) ...[
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Build message content
  static Widget _buildMessageContent(String message, SnackbarType type) {
    IconData icon;
    Color iconColor;
    
    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case SnackbarType.error:
        icon = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case SnackbarType.info:
      icon = Icons.info_outline;
        iconColor = Colors.blue;
        break;
    }
    
    return Container(
      height: 150,
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Enum for different snackbar types
enum SnackbarType {
  success,
  error,
  info,
}