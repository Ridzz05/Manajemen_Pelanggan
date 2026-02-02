# Manajemen Pelanggan 📱

A modern, minimalist Flutter application designed to streamline customer and service management for freelancers and small agencies.

![App Logo](assets/images/logo.png)

## ✨ Key Features

### 📊 Interactive Dashboard

- **Real-time Insights**: View monthly growth for customers and services.
- **Service Distribution**: Visualize popular service categories with interactive charts.
- **Recent Activity**: Quick access to the latest added customers and services.

### 👥 Customer Management

- **Detailed Profiles**: Store customer names, contact info (WhatsApp, Telegram, Email), and detailed notes.
- **Service Tracking**: Associate start and end dates for services to track deadlines.
- **Multi-Category Support**: Tag customers with multiple service categories (e.g., Website, Design).
- **Direct Communication**: One-tap action to contact customers via their preferred method.

### 🏷️ Service & Category Management

- **Category Control**: Easily add, remove, and manage service categories to adapt to your business offerings.
- **Flexible Catalog**: Define services with pricing and duration standards.

### 📅 Agenda & Timeline

- **Active Projects**: View all ongoing services sorted by deadlines.
- **History**: Access past projects and completed services.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Database**: [SQFlite](https://pub.dev/packages/sqflite)
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart)
- **Icons**: [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Java JDK 11+

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/manajemen_pelanggan.git
   cd manajemen_pelanggan
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Building for Release

To generate a release build for Android:

1. **Generate Icons** (Optional, if changed)

   ```bash
   dart run flutter_launcher_icons
   ```

2. **Build APK**

   ```bash
   flutter build apk --release
   ```

3. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
