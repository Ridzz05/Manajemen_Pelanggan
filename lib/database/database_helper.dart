import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/service.dart';

class DatabaseHelper {
  static const String _databaseName = 'awb_management.db';
  static const int _databaseVersion = 5; // Updated version for customer service columns

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    try {
      // Try to get the application documents directory
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, _databaseName);
    } catch (e) {
      // Fallback: Use a simple path for platforms where path_provider is not available
      // This is a temporary workaround - in production, you'd want to handle this better
      path = join('./', _databaseName);
      // Removed debug print statement for production
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle database upgrades
    );
  }

  Future _onCreate(Database db, int version) async {
    await _createBusinessProfilesTable(db);
    await _createCustomersTable(db);
    await _createServicesTable(db);
    await _insertDefaultBusinessProfile(db);
    await _insertDummyData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Removed debug print statement for production

    if (oldVersion < 2) {
      try {
        // Strategy: Drop and recreate customers table with new schema
        await _recreateCustomersTable(db);
      } catch (e) {
        // Removed debug print statement for production
        // If all else fails, try the safer migration approach
        await _migrateCustomersTableSafely(db);
      }
    }

    if (oldVersion < 3) {
      try {
        // Strategy: Drop and recreate services table with new schema
        await _recreateServicesTable(db);
      } catch (e) {
        // Removed debug print statement for production
        // If all else fails, try the safer migration approach
        await _migrateServicesTableSafely(db);
      }
    }

    if (oldVersion < 5) {
      try {
        // Add selected_service_id and selected_service_name columns to customers table
        await _migrateCustomersTableToServiceColumns(db);
      } catch (e) {
        // Removed debug print statement for production
        // If all else fails, try the safer migration approach
        await _migrateCustomersTableToServiceColumnsSafely(db);
      }
    }
  }

  Future _migrateCustomersTableSafely(Database db) async {
    try {
      // First, let's check if the new columns already exist
      final result = await db.rawQuery("PRAGMA table_info(customers)");
      final columns = result.map((row) => row['name'] as String).toList();

      // Add contact_method column if it doesn't exist
      if (!columns.contains('contact_method')) {
        await db.execute('ALTER TABLE customers ADD COLUMN contact_method TEXT NOT NULL DEFAULT "Email"');
        // Removed debug print statement for production
      }

      // Add contact_value column if it doesn't exist
      if (!columns.contains('contact_value')) {
        await db.execute('ALTER TABLE customers ADD COLUMN contact_value TEXT NOT NULL DEFAULT ""');
        // Removed debug print statement for production
      }

      // Make email column nullable if it exists - deprecated, but keeping for backward compatibility
      if (columns.contains('email')) {
        try {
          await db.execute('ALTER TABLE customers ALTER COLUMN email TEXT');
          // Removed debug print statement for production
        } catch (e) {
          // Removed debug print statement for production
        }
      }

      // Migrate existing email data to new structure - skip this since email field is deprecated
      // await db.execute('UPDATE customers SET contact_method = "Email", contact_value = email WHERE email IS NOT NULL AND (contact_value IS NULL OR contact_value = "")');

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }

  Future _recreateCustomersTable(Database db) async {
    try {
      // Removed debug print statement for production

      // Create temporary table with new structure
      await db.execute('''
        CREATE TABLE customers_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          contact_method TEXT NOT NULL DEFAULT 'Email',
          contact_value TEXT NOT NULL,
          phone TEXT NOT NULL DEFAULT '',
          address TEXT NOT NULL DEFAULT '', -- Made optional
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Copy existing data to backup table, handling null email
      await db.execute('''
        INSERT INTO customers_backup (id, name, contact_method, contact_value, phone, address, created_at, updated_at)
        SELECT
          id,
          name,
          'Email',
          COALESCE(email, ''),
          COALESCE(phone, ''),
          COALESCE(address, ''),
          created_at,
          updated_at
        FROM customers
      ''');

      // Drop old table
      await db.execute('DROP TABLE customers');

      // Rename backup table to customers
      await db.execute('ALTER TABLE customers_backup RENAME TO customers');

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }

  Future _createBusinessProfilesTable(Database db) async {
    await db.execute('''
      CREATE TABLE business_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT NOT NULL,
        business_description TEXT NOT NULL,
        business_logo TEXT NOT NULL,
        business_email TEXT NOT NULL,
        business_phone TEXT NOT NULL,
        business_address TEXT NOT NULL,
        business_website TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future _createCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact_method TEXT NOT NULL DEFAULT 'Email',
        contact_value TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '', -- Made optional with default empty string
        selected_service_id INTEGER, -- ID layanan yang dipilih pelanggan
        selected_service_name TEXT, -- Nama layanan yang dipilih
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
        price REAL NOT NULL,
        start_date TEXT,
        end_date TEXT,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future _insertDefaultBusinessProfile(Database db) async {
    final defaultProfile = BusinessProfile.defaultProfile();
    await db.insert('business_profiles', defaultProfile.toMap());
  }

  Future _insertDummyData(Database db) async {
    // Insert dummy customers
    final customers = [
      Customer(
        name: 'John Doe',
        contactMethod: 'WA Business',
        contactValue: '08123456789',
        phone: '08123456789', // Phone field kept for backward compatibility
        address: '', // Address field removed, set to empty string
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Jane Smith',
        contactMethod: 'Telegram',
        contactValue: '@janesmith',
        phone: '08198765432',
        address: '',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Bob Wilson',
        contactMethod: 'Email',
        contactValue: 'bob@example.com',
        phone: '08134567890',
        address: '',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Alice Johnson',
        contactMethod: 'WA Business',
        contactValue: '08145678901',
        phone: '08145678901',
        address: '',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Customer(
        name: 'Charlie Brown',
        contactMethod: 'Telegram',
        contactValue: '@charliebrown',
        phone: '08156789012',
        address: '',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];

    for (var customer in customers) {
      await db.insert('customers', customer.toMap());
    }
  }

  // Business Profile CRUD Operations
  Future<BusinessProfile?> getBusinessProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'business_profiles',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return BusinessProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertBusinessProfile(BusinessProfile profile) async {
    final db = await database;
    return await db.insert('business_profiles', profile.toMap());
  }

  Future<int> updateBusinessProfile(BusinessProfile profile) async {
    final db = await database;
    return await db.update(
      'business_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // Customer CRUD Operations
  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      orderBy: 'created_at DESC',
    );
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
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Service CRUD Operations
  Future<List<Service>> getAllServices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  // Get only active services (services that are currently active based on dates)
  Future<List<Service>> getActiveServices() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'services',
      where: 'start_date <= ? AND (end_date IS NULL OR end_date >= ?)',
      whereArgs: [now, now],
      orderBy: 'created_at DESC',
    );
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
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
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

  // Get monthly growth data for the last 6 months
  Future<Map<String, List<int>>> getMonthlyGrowthData({int months = 6}) async {
    final db = await database;

    // Get current date and calculate start date (6 months ago)
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - months + 1, 1);

    // Query customers count by month
    final customerResult = await db.rawQuery(
      'SELECT strftime(\'%Y-%m\', created_at) as month, COUNT(*) as count FROM customers WHERE created_at >= ? GROUP BY strftime(\'%Y-%m\', created_at) ORDER BY month ASC',
      [startDate.toIso8601String()],
    );

    // Query services count by month
    final serviceResult = await db.rawQuery(
      'SELECT strftime(\'%Y-%m\', created_at) as month, COUNT(*) as count FROM services WHERE created_at >= ? GROUP BY strftime(\'%Y-%m\', created_at) ORDER BY month ASC',
      [startDate.toIso8601String()],
    );

    // Convert results to maps
    Map<String, int> customerCounts = {};
    Map<String, int> serviceCounts = {};

    for (var row in customerResult) {
      customerCounts[row['month'] as String] = row['count'] as int;
    }

    for (var row in serviceResult) {
      serviceCounts[row['month'] as String] = row['count'] as int;
    }

    // Generate data for the last 6 months (fill missing months with 0)
    List<int> customers = [];
    List<int> services = [];

    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';

      customers.insert(0, customerCounts[monthKey] ?? 0);
      services.insert(0, serviceCounts[monthKey] ?? 0);
    }

    return {'customers': customers, 'services': services};
  }

  Future _migrateServicesTableSafely(Database db) async {
    try {
      // First, let's check if the new columns already exist
      final result = await db.rawQuery("PRAGMA table_info(services)");
      final columns = result.map((row) => row['name'] as String).toList();

      // Add duration_period column if it doesn't exist
      if (!columns.contains('duration_period')) {
        await db.execute('ALTER TABLE services ADD COLUMN duration_period TEXT NOT NULL DEFAULT "1 minggu"');
        // Removed debug print statement for production
      }

      // Update existing duration data to duration_period format
      await db.execute('UPDATE services SET duration_period = CAST(duration AS TEXT) || " menit" WHERE duration IS NOT NULL');

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }

  Future _migrateCustomersTableToServiceColumnsSafely(Database db) async {
    try {
      // First, let's check if the new columns already exist
      final result = await db.rawQuery("PRAGMA table_info(customers)");
      final columns = result.map((row) => row['name'] as String).toList();

      // Add selected_service_id column if it doesn't exist
      if (!columns.contains('selected_service_id')) {
        await db.execute('ALTER TABLE customers ADD COLUMN selected_service_id INTEGER');
        // Removed debug print statement for production
      }

      // Add selected_service_name column if it doesn't exist
      if (!columns.contains('selected_service_name')) {
        await db.execute('ALTER TABLE customers ADD COLUMN selected_service_name TEXT');
        // Removed debug print statement for production
      }

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }

  Future _migrateCustomersTableToServiceColumns(Database db) async {
    try {
      // Removed debug print statement for production

      // Create temporary table with new structure
      await db.execute('''
        CREATE TABLE customers_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          contact_method TEXT NOT NULL DEFAULT 'Email',
          contact_value TEXT NOT NULL,
          phone TEXT NOT NULL DEFAULT '',
          address TEXT NOT NULL DEFAULT '',
          selected_service_id INTEGER,
          selected_service_name TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Copy existing data to backup table
      await db.execute('''
        INSERT INTO customers_backup (id, name, contact_method, contact_value, phone, address, selected_service_id, selected_service_name, created_at, updated_at)
        SELECT
          id,
          name,
          contact_method,
          contact_value,
          phone,
          address,
          NULL as selected_service_id,
          NULL as selected_service_name,
          created_at,
          updated_at
        FROM customers
      ''');

      // Drop old table
      await db.execute('DROP TABLE customers');

      // Rename backup table to customers
      await db.execute('ALTER TABLE customers_backup RENAME TO customers');

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }


  Future _recreateServicesTable(Database db) async {
    try {
      // Removed debug print statement for production

      // Create temporary table with new structure
      await db.execute('''
        CREATE TABLE services_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          price REAL NOT NULL,
          start_date TEXT,
          end_date TEXT,
          category TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // Copy existing data to backup table
      await db.execute('''
        INSERT INTO services_backup (id, name, price, start_date, end_date, category, created_at, updated_at)
        SELECT
          id,
          name,
          price,
          start_date,
          end_date,
          category,
          created_at,
          updated_at
        FROM services
      ''');

      // Drop old table
      await db.execute('DROP TABLE services');

      // Rename backup table to services
      await db.execute('ALTER TABLE services_backup RENAME TO services');

      // Removed debug print statement for production
    } catch (e) {
      // Removed debug print statement for production
      throw e;
    }
  }
}
