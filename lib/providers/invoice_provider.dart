import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/invoice_model.dart';

class InvoiceProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'ALL';

  List<InvoiceModel> get invoices => _filteredInvoices;
  List<InvoiceModel> get allInvoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;

  List<InvoiceModel> get _filteredInvoices {
    if (_filterStatus == 'ALL') return _invoices;
    return _invoices.where((i) => i.status == _filterStatus).toList();
  }

  int get totalInvoices => _invoices.length;
  double get totalRevenue =>
      _invoices.where((i) => i.status == 'PAID').fold(0.0, (sum, i) => sum + i.amount);
  double get outstandingAmount =>
      _invoices.where((i) => i.status == 'PENDING' || i.status == 'OVERDUE').fold(0.0, (sum, i) => sum + i.amount);
  List<InvoiceModel> get recentInvoices => _invoices.take(5).toList();

  InvoiceProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    _setLoading(true);
    try {
      final box = Hive.box<InvoiceModel>('invoicesBox');
      _invoices = box.values.toList();
      _invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading invoices: $e');
    }
    _setLoading(false);
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<bool> addInvoice({
    required String clientId,
    required String clientName,
    required double amount,
    required double gstRate,
    required DateTime issueDate,
    required DateTime dueDate,
    required String status,
    String? notes,
    List<InvoiceItem>? items,
  }) async {
    try {
      final box = Hive.box<InvoiceModel>('invoicesBox');
      final invoiceCount = box.length + 1;
      final id = 'inv_${DateTime.now().millisecondsSinceEpoch}';
      final invoiceNumber =
          'INV-${DateTime.now().year}-${invoiceCount.toString().padLeft(4, '0')}';

      final invoice = InvoiceModel(
        id: id,
        invoiceNumber: invoiceNumber,
        clientId: clientId,
        clientName: clientName,
        amount: amount,
        gstRate: gstRate,
        issueDate: issueDate,
        dueDate: dueDate,
        status: status,
        notes: notes,
        items: items ?? [],
      );

      await box.put(id, invoice);
      _invoices.insert(0, invoice);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInvoiceStatus(String invoiceId, String newStatus) async {
    try {
      final box = Hive.box<InvoiceModel>('invoicesBox');
      final invoice = box.get(invoiceId);
      if (invoice != null) {
        final updated = InvoiceModel(
          id: invoice.id,
          invoiceNumber: invoice.invoiceNumber,
          clientId: invoice.clientId,
          clientName: invoice.clientName,
          amount: invoice.amount,
          gstRate: invoice.gstRate,
          issueDate: invoice.issueDate,
          dueDate: invoice.dueDate,
          status: newStatus,
          notes: invoice.notes,
          items: invoice.items,
          createdAt: invoice.createdAt,
        );
        await box.put(invoiceId, updated);
        final idx = _invoices.indexWhere((i) => i.id == invoiceId);
        if (idx != -1) {
          _invoices[idx] = updated;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInvoice(String invoiceId) async {
    try {
      final box = Hive.box<InvoiceModel>('invoicesBox');
      await box.delete(invoiceId);
      _invoices.removeWhere((i) => i.id == invoiceId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
