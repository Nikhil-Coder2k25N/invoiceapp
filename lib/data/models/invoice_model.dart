import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 1)
class InvoiceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(2)
  final String clientId;

  @HiveField(3)
  final String clientName;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final DateTime issueDate;

  @HiveField(6)
  final DateTime dueDate;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final DateTime createdAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}