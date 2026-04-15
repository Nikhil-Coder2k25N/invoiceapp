import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/invoice_model.dart';
import '../data/models/client_model.dart';

class DashboardProvider extends ChangeNotifier {
  List<InvoiceModel> _recentInvoices = [];
  double _totalRevenue = 0.0;
  double _outstandingAmount = 0.0;
  int _totalInvoices = 0;
  int _totalClients = 0;
  bool _isLoading = false;
  String _userName = 'Alex Morgan';

  List<InvoiceModel> get recentInvoices => _recentInvoices;
  double get totalRevenue => _totalRevenue;
  double get outstandingAmount => _outstandingAmount;
  int get totalInvoices => _totalInvoices;
  int get totalClients => _totalClients;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get greeting => _getGreeting();

  DashboardProvider() {
    initializeData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> initializeData() async {
    _setLoading(true);

    try {
      await _loadUserName();
      await _seedInitialData();
      await loadDashboardData();
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }

    _setLoading(false);
  }

  Future<void> _loadUserName() async {
    try {
      final userBox = Hive.box('userBox');
      final fullName = userBox.get('fullName');
      if (fullName != null && fullName.toString().isNotEmpty) {
        _userName = fullName.toString();
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  Future<void> _seedInitialData() async {
    try {
      final invoiceBox = Hive.box<InvoiceModel>('invoicesBox');

      // Only seed if empty
      if (invoiceBox.isEmpty) {
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
          await invoiceBox.put(invoice.id, invoice);
        }
      }

      // Seed client data
      final clientBox = Hive.box<ClientModel>('clientsBox');
      if (clientBox.isEmpty) {
        final sampleClients = [
          ClientModel(
            id: 'client_001',
            name: 'Acme Corp',
            email: 'billing@acmecorp.com',
            company: 'Acme Corporation',
            totalInvoiced: 1250.00,
            outstandingAmount: 0.0,
          ),
          ClientModel(
            id: 'client_002',
            name: 'Global Tech',
            email: 'accounts@globaltech.com',
            company: 'Global Tech Solutions',
            totalInvoiced: 850.50,
            outstandingAmount: 850.50,
          ),
          ClientModel(
            id: 'client_003',
            name: 'Startup Inc',
            email: 'finance@startupinc.com',
            company: 'Startup Inc',
            totalInvoiced: 3200.00,
            outstandingAmount: 3200.00,
          ),
        ];

        for (var client in sampleClients) {
          await clientBox.put(client.id, client);
        }
      }
    } catch (e) {
      debugPrint('Error seeding data: $e');
    }
  }

  Future<void> loadDashboardData() async {
    try {
      final invoiceBox = Hive.box<InvoiceModel>('invoicesBox');
      final invoices = invoiceBox.values.toList();

      // Calculate totals
      _totalRevenue = 0.0;
      _outstandingAmount = 0.0;

      for (var invoice in invoices) {
        if (invoice.status == 'PAID') {
          _totalRevenue += invoice.amount;
        } else {
          _outstandingAmount += invoice.amount;
        }
      }

      _totalInvoices = invoices.length;

      // Get client count
      try {
        final clientBox = Hive.box<ClientModel>('clientsBox');
        _totalClients = clientBox.length;
      } catch (e) {
        _totalClients = 3; // Fallback value
      }

      // Get recent invoices
      invoices.sort((a, b) => b.issueDate.compareTo(a.issueDate));
      _recentInvoices = invoices.take(3).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}