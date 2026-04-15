import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _userName = '';
  String _businessName = '';

  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get businessName => _businessName;
  String get greeting => _getGreeting();

  DashboardProvider() {
    loadUserInfo();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> loadUserInfo() async {
    _setLoading(true);
    try {
      final authBox = Hive.box('authBox');
      final email = authBox.get('currentUser');
      if (email != null) {
        final userBox = Hive.box<dynamic>('userBox');
        final user = userBox.get(email);
        if (user != null) {
          _userName = user.fullName ?? '';
          _businessName = user.businessName ?? '';
        }
      }
      // Fallback
      if (_userName.isEmpty) {
        final userBox = Hive.box('userBox');
        _userName = userBox.get('fullName', defaultValue: '') ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void refresh() {
    loadUserInfo();
    notifyListeners();
  }
}