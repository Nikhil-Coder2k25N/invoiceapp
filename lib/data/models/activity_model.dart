import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 3)
class ActivityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String? invoiceId;

  @HiveField(5)
  final String? clientId;

  @HiveField(6)
  final double? amount;

  @HiveField(7)
  final DateTime timestamp;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.invoiceId,
    this.clientId,
    this.amount,
    required this.timestamp,
  });

  ActivityModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? invoiceId,
    String? clientId,
    double? amount,
    DateTime? timestamp,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      invoiceId: invoiceId ?? this.invoiceId,
      clientId: clientId ?? this.clientId,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'invoiceId': invoiceId,
      'clientId': clientId,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, type: $type, title: $title)';
  }
}