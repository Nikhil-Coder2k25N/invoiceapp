import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_model.dart';

class HiveHelper {
  HiveHelper._();

  static const String userBoxName = 'userBox';
  static const String authBoxName = 'authBox';
  static const String currentUserKey = 'currentUser';
  static const String isLoggedInKey = 'isLoggedIn';

  static Box<UserModel> getUserBox() {
    return Hive.box<UserModel>(userBoxName);
  }

  static Box getAuthBox() {
    return Hive.box(authBoxName);
  }

  static Future<void> saveUser(UserModel user) async {
    final userBox = getUserBox();
    await userBox.put(user.email, user);
  }

  static UserModel? getUser(String email) {
    final userBox = getUserBox();
    return userBox.get(email);
  }

  static Future<void> setCurrentUser(UserModel user) async {
    final authBox = getAuthBox();
    await authBox.put(currentUserKey, user.email);
    await authBox.put(isLoggedInKey, true);
  }

  static UserModel? getCurrentUser() {
    final authBox = getAuthBox();
    final email = authBox.get(currentUserKey);
    if (email != null) {
      return getUser(email);
    }
    return null;
  }

  static bool isUserLoggedIn() {
    final authBox = getAuthBox();
    return authBox.get(isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final authBox = getAuthBox();
    await authBox.put(isLoggedInKey, false);
    await authBox.delete(currentUserKey);
  }

  static Future<void> clearAllData() async {
    await getUserBox().clear();
    await getAuthBox().clear();
    await Hive.box('invoicesBox').clear();
    await Hive.box('clientsBox').clear();
  }
}