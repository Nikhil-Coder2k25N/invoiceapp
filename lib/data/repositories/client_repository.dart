import 'package:hive_flutter/hive_flutter.dart';
import '../models/client_model.dart';

class ClientRepository {
  static const String _boxName = 'clientsBox';

  Box<ClientModel>? _box;

  Future<Box<ClientModel>> get box async {
    _box ??= await Hive.openBox<ClientModel>(_boxName);
    return _box!;
  }

  Future<List<ClientModel>> getAllClients() async {
    final clientBox = await box;
    return clientBox.values.toList();
  }

  Future<int> getClientCount() async {
    final clients = await getAllClients();
    return clients.length;
  }

  Future<void> saveClient(ClientModel client) async {
    final clientBox = await box;
    await clientBox.put(client.id, client);
  }

  Future<void> updateClientOutstanding(String clientId, double amount) async {
    final clientBox = await box;
    final client = clientBox.get(clientId);
    if (client != null) {
      final updatedClient = ClientModel(
        id: client.id,
        name: client.name,
        email: client.email,
        phone: client.phone,
        company: client.company,
        address: client.address,
        totalInvoiced: client.totalInvoiced,
        outstandingAmount: client.outstandingAmount + amount,
        createdAt: client.createdAt,
      );
      await clientBox.put(clientId, updatedClient);
    }
  }

  Future<void> deleteClient(String clientId) async {
    final clientBox = await box;
    await clientBox.delete(clientId);
  }

  Future<void> seedSampleData() async {
    final existingClients = await getAllClients();
    if (existingClients.isEmpty) {
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
        await saveClient(client);
      }
    }
  }
}