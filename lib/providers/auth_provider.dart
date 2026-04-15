import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    _currentUser = _authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    String? businessName,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authRepository.signUp(
        fullName: fullName,
        email: email,
        password: password,
        businessName: businessName,
        phone: phone,
      );
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? fullName,
    String? businessName,
    String? gstin,
    String? phone,
    String? address,
    String? state,
  }) async {
    _setLoading(true);
    try {
      if (_currentUser != null) {
        final updated = _currentUser!.copyWith(
          fullName: fullName,
          businessName: businessName,
          gstin: gstin,
          phone: phone,
          address: address,
          state: state,
        );
        await _authRepository.updateUser(updated);
        _currentUser = updated;
        _setLoading(false);
        notifyListeners();
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}