import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackHandlerService {
  static DateTime? _lastBackPressTime;
  static const int _backPressThreshold = 2000; // 2 seconds threshold
  static int _backPressCount = 0;
  static const int _maxBackPress = 3; // Maximum number of back presses allowed

  static Future<bool> handleBackPress(BuildContext context) async {
    if (_lastBackPressTime == null) {
      _lastBackPressTime = DateTime.now();
      _backPressCount = 1;
      _showToast(context, 'Press back again to exit');
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(_lastBackPressTime!).inMilliseconds;

    if (difference < _backPressThreshold) {
      _backPressCount++;
      
      if (_backPressCount >= _maxBackPress) {
        return await _showExitConfirmationDialog(context);
      } else {
        _showToast(context, 'Press back ${_maxBackPress - _backPressCount} more times to exit');
        _lastBackPressTime = now;
        return false;
      }
    } else {
      _lastBackPressTime = now;
      _backPressCount = 1;
      _showToast(context, 'Press back again to exit');
      return false;
    }
  }

  static Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Application'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Reset the counter when user confirms exit
      _backPressCount = 0;
      _lastBackPressTime = null;
      return true;
    }
    
    // Reset the counter when user cancels
    _backPressCount = 0;
    _lastBackPressTime = null;
    return false;
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Method to explicitly handle sign out
  static void handleSignOut() {
    _backPressCount = 0;
    _lastBackPressTime = null;
  }
}
