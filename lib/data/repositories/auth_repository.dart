import '../../core/utils/hive_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final existingUser = HiveHelper.getUser(email);

      if (existingUser != null) {
        throw Exception('User already exists');
      }

      final user = UserModel(
        fullName: fullName,
        email: email,
        password: password,
      );

      await HiveHelper.saveUser(user);
      await HiveHelper.setCurrentUser(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = HiveHelper.getUser(email);

      if (user == null) {
        throw Exception('User not found');
      }

      if (user.password != password) {
        throw Exception('Invalid password');
      }

      await HiveHelper.setCurrentUser(user);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await HiveHelper.logout();
  }

  UserModel? getCurrentUser() {
    return HiveHelper.getCurrentUser();
  }

  bool isUserLoggedIn() {
    return HiveHelper.isUserLoggedIn();
  }
}