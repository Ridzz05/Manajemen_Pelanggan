import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/service.dart';

class DatabaseHelper {
  static const String _databaseName = 'awb_management.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createCustomersTable(db);
    await _createServicesTable(db);
    await _createBusinessProfilesTable(db);
    await _insertDummyData(db);
    await _insertDefaultBusinessProfile(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
  }

  Future _createCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        duration INTEGER NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future _insertDummyData(Database db) async {
    // Insert dummy customers
    final customers = [
      Customer(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '08123456789',
        address: 'Jakarta Selatan',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '08198765432',
        address: 'Jakarta Pusat',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Bob Wilson',
        email: 'bob@example.com',
        phone: '08134567890',
        address: 'Jakarta Utara',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Alice Johnson',
        email: 'alice@example.com',
        phone: '08145678901',
        address: 'Jakarta Barat',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Charlie Brown',
        email: 'charlie@example.com',
        phone: '08156789012',
        address: 'Jakarta Timur',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var customer in customers) {
      await db.insert('customers', customer.toMap());
    }

    // Insert dummy services
    final services = [
      Service(
        name: 'Cuci Mobil',
        description: 'Layanan cuci mobil lengkap dengan wax',
        price: 50000,
        duration: 60,
        category: 'Perawatan',
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now(),
      ),
      Service(
        name: 'Ganti Oli',
        description: 'Penggantian oli mesin dan filter',
        price: 150000,
        duration: 45,
        category: 'Perawatan',
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now(),
      ),
      Service(
        name: 'Tune Up',
        description: 'Tune up mesin dan penggantian busi',
        price: 300000,
        duration: 120,
        category: 'Perbaikan',
        createdAt: DateTime.now().subtract(const Duration(days: 21)),
        updatedAt: DateTime.now(),
      ),
      Service(
        name: 'Ban Tubeless',
        description: 'Pemasangan ban tubeless baru',
        price: 80000,
        duration: 30,
        category: 'Perbaikan',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
      ),
      Service(
        name: 'Detailing Interior',
        description: 'Pembersihan interior mobil secara menyeluruh',
        price: 200000,
        duration: 90,
        category: 'Perawatan',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var service in services) {
      await db.insert('services', service.toMap());
    }
  }

  // Customer CRUD Operations
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Service CRUD Operations
  Future<List<Service>> getAllServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('services', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<Service?> getService(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Service.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<int> updateService(Service service) async {
    final db = await database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Statistics methods
  Future<List<Customer>> getRecentCustomers({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  Future<List<Service>> getRecentServices({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<Map<String, int>> getServiceCategoryCount() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM services GROUP BY category ORDER BY count DESC',
    );

    Map<String, int> categoryCount = {};
    for (var row in result) {
      categoryCount[row['category']] = row['count'];
    }
    return categoryCount;
  }
}
