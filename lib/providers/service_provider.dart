import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/service.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  List<Service> _filteredServices = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Service> get services => _services;
  List<Service> get filteredServices => _filteredServices;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Get unique categories
  List<String> get categories {
    final categories = _services.map((service) => service.category).toSet().toList();
    categories.insert(0, 'Semua');
    return categories;
  }

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;
      _services = await dbHelper.getAllServices();
      _filteredServices = _services;
    } catch (e) {
      print('Error loading services: $e');
      _services = [];
      _filteredServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchServices(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _services;

    // Apply category filter
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((service) => service.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) {
        return service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               service.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               service.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    _filteredServices = filtered;
    notifyListeners();
  }

  Future<bool> addService(Service service) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final id = await dbHelper.insertService(service);
      if (id > 0) {
        await loadServices(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding service: $e');
      return false;
    }
  }

  Future<bool> updateService(Service service) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final rowsAffected = await dbHelper.updateService(service);
      if (rowsAffected > 0) {
        await loadServices(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating service: $e');
      return false;
    }
  }

  Future<bool> deleteService(int id) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final rowsAffected = await dbHelper.deleteService(id);
      if (rowsAffected > 0) {
        await loadServices(); // Refresh list
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }
}
