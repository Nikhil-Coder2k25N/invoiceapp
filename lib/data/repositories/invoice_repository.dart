import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  static const String _boxName = 'invoicesBox';

  Box<InvoiceModel>? _box;

  Future<Box<InvoiceModel>> get box async {
    _box ??= await Hive.openBox<InvoiceModel>(_boxName);
    return _box!;
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    final invoiceBox = await box;
    return invoiceBox.values.toList();
  }

  Future<List<InvoiceModel>> getRecentInvoices({int limit = 5}) async {
    final invoices = await getAllInvoices();
    invoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));
    return invoices.take(limit).toList();
  }

  Future<double> getTotalRevenue() async {
    final invoices = await getAllInvoices();
    double total = 0.0;
    for (var invoice in invoices) {
      if (invoice.status == 'PAID') {
        total += invoice.amount;
      }
    }
    return total;
  }

  Future<double> getOutstandingAmount() async {
    final invoices = await getAllInvoices();
    double total = 0.0;
    for (var invoice in invoices) {
      if (invoice.status == 'PENDING' || invoice.status == 'OVERDUE') {
        total += invoice.amount;
      }
    }
    return total;
  }

  Future<int> getInvoiceCount() async {
    final invoices = await getAllInvoices();
    return invoices.length;
  }

  Future<void> saveInvoice(InvoiceModel invoice) async {
    final invoiceBox = await box;
    await invoiceBox.put(invoice.id, invoice);
  }

  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    final invoiceBox = await box;
    final invoice = invoiceBox.get(invoiceId);
    if (invoice != null) {
      // Create a new invoice with updated status
      final updatedInvoice = InvoiceModel(
        id: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        clientId: invoice.clientId,
        clientName: invoice.clientName,
        amount: invoice.amount,
        issueDate: invoice.issueDate,
        dueDate: invoice.dueDate,
        status: status,
        createdAt: invoice.createdAt,
      );
      await invoiceBox.put(invoiceId, updatedInvoice);
    }
  }

  Future<void> deleteInvoice(String invoiceId) async {
    final invoiceBox = await box;
    await invoiceBox.delete(invoiceId);
  }

  Future<void> seedSampleData() async {
    final existingInvoices = await getAllInvoices();
    if (existingInvoices.isEmpty) {
      final sampleInvoices = [
        InvoiceModel(
          id: 'inv_001',
          invoiceNumber: 'INV-2024-001',
          clientId: 'client_001',
          clientName: 'Acme Corp',
          amount: 1250.00,
          issueDate: DateTime(2024, 10, 12),
          dueDate: DateTime(2024, 11, 12),
          status: 'PAID',
        ),
        InvoiceModel(
          id: 'inv_002',
          invoiceNumber: 'INV-2024-002',
          clientId: 'client_002',
          clientName: 'Global Tech',
          amount: 850.50,
          issueDate: DateTime(2024, 10, 15),
          dueDate: DateTime(2024, 11, 15),
          status: 'PENDING',
        ),
        InvoiceModel(
          id: 'inv_003',
          invoiceNumber: 'INV-2024-003',
          clientId: 'client_003',
          clientName: 'Startup Inc',
          amount: 3200.00,
          issueDate: DateTime(2024, 9, 28),
          dueDate: DateTime(2024, 10, 28),
          status: 'OVERDUE',
        ),
      ];

      for (var invoice in sampleInvoices) {
        await saveInvoice(invoice);
      }
    }
  }
}