import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool _hasNetworkError = false;
  
  bool get isOnline => _isOnline;
  bool get hasNetworkError => _hasNetworkError;
  
  void setOnlineStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      _hasNetworkError = !status;
      notifyListeners();
    }
  }
  
  void clearNetworkError() {
    _hasNetworkError = false;
    notifyListeners();
  }
  
  // Simple connectivity check for Firebase operations
  Future<bool> checkConnectivity() async {
    try {
      // For web/desktop, we assume connectivity unless Firebase fails
      return true;
    } catch (e) {
      setOnlineStatus(false);
      return false;
    }
  }
}
