import 'package:hive/hive.dart';

part 'client_model.g.dart';

@HiveType(typeId: 2)
class ClientModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? company;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final double totalInvoiced;

  @HiveField(7)
  final double outstandingAmount;

  @HiveField(8)
  final DateTime createdAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.company,
    this.address,
    this.totalInvoiced = 0.0,
    this.outstandingAmount = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    double? totalInvoiced,
    double? outstandingAmount,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      totalInvoiced: totalInvoiced ?? this.totalInvoiced,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'totalInvoiced': totalInvoiced,
      'outstandingAmount': outstandingAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ClientModel(id: $id, name: $name, email: $email)';
  }
}