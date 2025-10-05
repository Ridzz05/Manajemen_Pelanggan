# 📁 Struktur Proyek Flutter - Refactoring Guide

## 🎯 Tujuan Refactoring

Refactoring dilakukan untuk mengatasi kompleksitas kode pada screens dengan memecah menjadi komponen-komponen kecil yang lebih mudah dipahami, di-maintain, dan di-test.

## 🏗️ Struktur Baru

### **Screens Structure**
```
lib/screens/
├── shared/
│   └── widgets/                    # Reusable widgets untuk semua screen
│       ├── stats_card.dart         # Widget untuk statistik cards
│       ├── recent_activity_card.dart # Widget untuk aktivitas terbaru
│       ├── screen_header.dart      # Widget header screen
│       ├── popular_service_card.dart # Widget layanan populer
│       ├── custom_search_bar.dart  # Widget search bar
│       ├── chart_container.dart    # Widget container untuk charts
│       └── common_widgets.dart     # Widget umum (loading, error, card)
│
├── home/
│   ├── home_screen_refactored.dart # Screen utama yang sudah direfactor
│   └── components/                 # Komponen khusus home screen
│       ├── home_header.dart        # Header untuk home screen
│       └── home_statistics_section.dart # Section statistik
│
└── agenda/
    ├── agenda_screen_refactored.dart # Screen utama yang sudah direfactor
    └── components/                  # Komponen khusus agenda screen
        ├── agenda_header.dart       # Header untuk agenda screen
        ├── service_card.dart        # Card untuk setiap layanan
        ├── service_list.dart        # List layanan dengan state management
        ├── services_empty_state.dart # Empty state untuk layanan kosong
        ├── edit_service_dialog.dart # Dialog edit layanan
        └── delete_service_dialog.dart # Dialog konfirmasi hapus
```

### **Services Structure**
```
lib/services/
└── app_services.dart               # Business logic dan utilities
    ├── ValidationService           # Validasi form dan input
    └── FormatService              # Formatting data untuk display
```

## 🔧 Komponen Breakdown

### **Sebelum Refactoring:**
- `home_screen.dart`: 452 lines - semua dalam satu file
- `agenda_screen.dart`: 494 lines - kompleks dengan banyak logic

### **Setelah Refactoring:**
- **Home Screen**: 36 lines → komponen terpisah
- **Agenda Screen**: 68 lines → komponen terpisah
- **Reusable Widgets**: 8+ komponen siap pakai
- **Services**: Logic bisnis terpisah untuk validasi dan formatting

## 🎨 Reusable Widgets

### **StatsCard & SummaryCard**
```dart
// Penggunaan di berbagai screen
SummaryCard(
  title: 'Total Pelanggan',
  value: stats.totalCustomers.toString(),
  icon: Icons.people_rounded,
  color: Colors.blue,
)
```

### **CustomSearchBar**
```dart
// Search bar yang bisa digunakan di semua screen
CustomSearchBar(
  controller: _searchController,
  hintText: 'Cari layanan...',
  onChanged: (value) => provider.searchServices(value),
)
```

### **RecentActivityCard**
```dart
// Menampilkan aktivitas terbaru dengan format tanggal
RecentActivityCard(
  title: customer.name,
  subtitle: 'Pelanggan baru ditambahkan',
  icon: Icons.person_add_rounded,
  color: Colors.blue,
  date: customer.createdAt,
  formatDate: formatActivityDate,
)
```

## 🛠️ Business Logic Services

### **ValidationService**
```dart
// Validasi form sebelum submit
final errors = ValidationService.validateServiceForm(
  name: name,
  description: description,
  price: price,
  duration: duration,
  category: category,
);

if (errors.isEmpty) {
  // Submit form
}
```

### **FormatService**
```dart
// Format data untuk display
Text(
  FormatService.formatCurrency(service.price),
  style: Theme.of(context).textTheme.titleMedium,
)

// Format durasi
Text(
  FormatService.formatDuration(service.duration),
  style: Theme.of(context).textTheme.bodySmall,
)
```

## 📋 Keuntungan Refactoring

### **1. Maintainability**
- ✅ Kode lebih mudah dibaca dan dipahami
- ✅ Setiap komponen memiliki tanggung jawab tunggal
- ✅ Perubahan pada satu komponen tidak mempengaruhi yang lain

### **2. Reusability**
- ✅ Widget bisa digunakan di berbagai screen
- ✅ Logic bisnis bisa digunakan ulang
- ✅ Consistent UI patterns di seluruh aplikasi

### **3. Testability**
- ✅ Setiap komponen bisa di-test secara terpisah
- ✅ Business logic terpisah dari UI
- ✅ Mock data lebih mudah untuk testing

### **4. Scalability**
- ✅ Penambahan fitur baru lebih mudah
- ✅ Screen baru bisa menggunakan komponen existing
- ✅ Tim development bisa bekerja paralel pada komponen berbeda

## 🚀 Cara Menggunakan

### **Untuk Screen Baru:**
1. Import reusable widgets dari `shared/widgets/`
2. Gunakan service classes untuk business logic
3. Ikuti struktur komponen yang sudah ada

### **Untuk Widget Baru:**
1. Buat di folder `shared/widgets/` jika reusable
2. Buat di folder `screen/components/` jika khusus screen tertentu
3. Ikuti pattern dan styling yang sudah ada

## 🔄 Migrasi dari Kode Lama

### **Langkah-langkah:**
1. **Backup** kode lama sebelum migrasi
2. **Test** komponen baru satu per satu
3. **Replace** import statements di screen utama
4. **Verify** semua fungsionalitas masih bekerja
5. **Remove** kode lama setelah yakin semuanya berfungsi

### **File yang Bisa Dihapus:**
- `lib/screens/home_screen.dart` (gunakan `home_screen_refactored.dart`)
- `lib/screens/agenda_screen.dart` (gunakan `agenda_screen_refactored.dart`)

## 🎯 Best Practices

### **Widget Structure:**
```dart
// ✅ Baik - Single Responsibility
class CustomerCard extends StatelessWidget {
  final Customer customer;
  // Hanya handle display customer data
}

// ❌ Buruk - Multiple Responsibilities
class CustomerScreen extends StatefulWidget {
  // Handle UI, business logic, validation, API calls
}
```

### **Service Usage:**
```dart
// ✅ Baik - Separate concerns
class CustomerScreen extends StatelessWidget {
  void _handleSubmit() {
    final errors = ValidationService.validateCustomerForm(...);
    if (errors.isEmpty) {
      CustomerService.addCustomer(...);
    }
  }
}
```

### **Component Naming:**
- `screen_name.dart` - Screen utama
- `screen_name_component.dart` - Komponen khusus screen
- `shared_widget_name.dart` - Widget reusable

## 🔧 Tools untuk Development

### **Code Generation:**
- **json_serializable** untuk model classes
- **freezed** untuk union types dan pattern matching

### **Testing:**
- **flutter_test** untuk unit tests
- **integration_test** untuk integration tests
- **mockito** untuk mocking dependencies

### **Linting:**
- **flutter_lints** untuk code quality
- **dart_code_metrics** untuk complexity analysis

---

**Struktur ini akan membuat kode Anda lebih maintainable, scalable, dan mudah untuk dikembangkan oleh tim! 🚀**
