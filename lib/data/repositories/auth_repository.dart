import '../../core/utils/hive_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
    String? businessName,
    String? phone,
  }) async {
    final existingUser = HiveHelper.getUser(email);
    if (existingUser != null) {
      throw Exception('An account with this email already exists');
    }
    final user = UserModel(
      fullName: fullName,
      email: email,
      password: password,
      businessName: businessName,
      phone: phone,
    );
    await HiveHelper.saveUser(user);
    await HiveHelper.setCurrentUser(user);
    return user;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final user = HiveHelper.getUser(email);
    if (user == null) {
      throw Exception('No account found with this email');
    }
    if (user.password != password) {
      throw Exception('Incorrect password. Please try again.');
    }
    await HiveHelper.setCurrentUser(user);
    return user;
  }

  Future<void> signOut() async {
    await HiveHelper.logout();
  }

  Future<void> updateUser(UserModel user) async {
    await HiveHelper.saveUser(user);
  }

  UserModel? getCurrentUser() {
    return HiveHelper.getCurrentUser();
  }

  bool isUserLoggedIn() {
    return HiveHelper.isUserLoggedIn();
  }
}