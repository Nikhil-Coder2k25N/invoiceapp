import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String fullName;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? updatedAt;

  @HiveField(5)
  final String? businessName;

  @HiveField(6)
  final String? gstin;

  @HiveField(7)
  final String? phone;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final String? state; // Indian state

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    DateTime? createdAt,
    this.updatedAt,
    this.businessName,
    this.gstin,
    this.phone,
    this.address,
    this.state,
  }) : createdAt = createdAt ?? DateTime.now();

  UserModel copyWith({
    String? fullName,
    String? email,
    String? password,
    DateTime? updatedAt,
    String? businessName,
    String? gstin,
    String? phone,
    String? address,
    String? state,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      businessName: businessName ?? this.businessName,
      gstin: gstin ?? this.gstin,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      state: state ?? this.state,
    );
  }

  @override
  String toString() {
    return 'UserModel(fullName: $fullName, email: $email)';
  }
}