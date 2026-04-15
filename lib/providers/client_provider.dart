import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/client_model.dart';

class ClientProvider extends ChangeNotifier {
  List<ClientModel> _clients = [];
  bool _isLoading = false;
  String? _error;

  List<ClientModel> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalClients => _clients.length;

  ClientProvider() {
    loadClients();
  }

  Future<void> loadClients() async {
    _setLoading(true);
    try {
      final box = Hive.box<ClientModel>('clientsBox');
      _clients = box.values.toList();
      _clients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading clients: $e');
    }
    _setLoading(false);
  }

  Future<bool> addClient({
    required String name,
    required String email,
    String? phone,
    String? company,
    String? address,
    String? gstin,
    String? pan,
  }) async {
    try {
      final box = Hive.box<ClientModel>('clientsBox');
      final id = 'client_${DateTime.now().millisecondsSinceEpoch}';
      final client = ClientModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        company: company,
        address: address,
        gstin: gstin,
        pan: pan,
      );
      await box.put(id, client);
      _clients.insert(0, client);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateClient(ClientModel updated) async {
    try {
      final box = Hive.box<ClientModel>('clientsBox');
      await box.put(updated.id, updated);
      final idx = _clients.indexWhere((c) => c.id == updated.id);
      if (idx != -1) {
        _clients[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteClient(String clientId) async {
    try {
      final box = Hive.box<ClientModel>('clientsBox');
      await box.delete(clientId);
      _clients.removeWhere((c) => c.id == clientId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateClientTotals(
      String clientId, double invoicedAmount, double outstandingAmount) async {
    try {
      final box = Hive.box<ClientModel>('clientsBox');
      final client = box.get(clientId);
      if (client != null) {
        final updated = ClientModel(
          id: client.id,
          name: client.name,
          email: client.email,
          phone: client.phone,
          company: client.company,
          address: client.address,
          gstin: client.gstin,
          pan: client.pan,
          totalInvoiced: client.totalInvoiced + invoicedAmount,
          outstandingAmount: client.outstandingAmount + outstandingAmount,
          createdAt: client.createdAt,
        );
        await box.put(clientId, updated);
        final idx = _clients.indexWhere((c) => c.id == clientId);
        if (idx != -1) {
          _clients[idx] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating client totals: $e');
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
