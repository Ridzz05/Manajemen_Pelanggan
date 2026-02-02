import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Customer> get customers => _customers;
  List<Customer> get filteredCustomers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Customer> getCustomersByCategory(String category) {
    if (category == 'Semua') return _customers;
    return _customers.where((c) => c.serviceCategories.contains(category)).toList();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;
      _customers = await dbHelper.getAllCustomers();
      _filteredCustomers = _customers;
    } catch (e) {
      // Removed debug print statement for production
      _customers = [];
      _filteredCustomers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredCustomers = _customers;
    } else {
      _filteredCustomers = _customers.where((customer) {
        return customer.name.toLowerCase().contains(query.toLowerCase()) ||
               customer.phone.contains(query) ||
               customer.contactValue.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> addCustomer(Customer customer) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final id = await dbHelper.insertCustomer(customer);
      if (id > 0) {
        await loadCustomers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      // Removed debug print statement for production
      return false;
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final rowsAffected = await dbHelper.updateCustomer(customer);
      if (rowsAffected > 0) {
        await loadCustomers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      // Removed debug print statement for production
      return false;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final rowsAffected = await dbHelper.deleteCustomer(id);
      if (rowsAffected > 0) {
        await loadCustomers(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      // Removed debug print statement for production
      return false;
    }
  }
}
