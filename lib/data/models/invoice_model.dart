import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 1)
class InvoiceItem {
  @HiveField(0)
  final String description;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double unitPrice;

  @HiveField(3)
  final double total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  }) : total = quantity * unitPrice;
}

@HiveType(typeId: 10)
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
  final String status; // PAID, PENDING, OVERDUE

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final double gstRate; // e.g. 18.0 for 18%

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final List<InvoiceItem> items;

  double get subtotal => items.isEmpty ? amount : items.fold(0, (s, i) => s + i.total);
  double get gstAmount => subtotal * (gstRate / 100);
  double get totalWithGst => subtotal + gstAmount;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.gstRate = 0.0,
    this.notes,
    List<InvoiceItem>? items,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        items = items ?? [];
}