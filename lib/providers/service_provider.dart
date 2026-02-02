import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/service.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> _services = [];
  List<Service> _filteredServices = [];
  List<String> _categories = []; // Loaded from DB
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Service> get services => _services;
  List<Service> get activeServices => _services.where((service) => service.isActive).toList();
  List<Service> get filteredServices => _filteredServices;
  List<String> get categories => _categories; // Expose categories directly
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final dbHelper = DatabaseHelper.instance;
      _categories = await dbHelper.getCategories();
    } catch (e) {
      print('Error loading categories: $e');
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory(String categoryName) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertCategory(categoryName);
      await loadCategories();
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryName) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.deleteCategory(categoryName);
      await loadCategories();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;
      _services = await dbHelper.getAllServices();
      _filteredServices = _services;
      
      // Also load categories when loading services (optional, but good practice)
      _categories = await dbHelper.getCategories();
      
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
        await loadServices();
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
        await loadServices();
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
        await loadServices();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting service: $e');
      return false;
    }
  }
}
