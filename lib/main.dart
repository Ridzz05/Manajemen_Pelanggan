// melakukan import package material.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyek_mahasiswa/theme/app_theme.dart';
import 'package:proyek_mahasiswa/screens/main_screen.dart';
import 'package:proyek_mahasiswa/providers/statistics_provider.dart';
import 'package:proyek_mahasiswa/providers/customer_provider.dart';
import 'package:proyek_mahasiswa/providers/service_provider.dart';
import 'package:proyek_mahasiswa/providers/profile_provider.dart';
import 'package:proyek_mahasiswa/constants/app_config.dart';

void main() {
  // Initialize sqflite for desktop platforms
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(isProduction: AppConfig.isProduction));
}

class MyApp extends StatelessWidget {
  final bool isProduction;

  const MyApp({super.key, this.isProduction = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StatisticsProvider()),
        ChangeNotifierProvider(create: (context) => CustomerProvider()),
        ChangeNotifierProvider(create: (context) => ServiceProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'Manajemen Pelanggan',
        debugShowCheckedModeBanner: !isProduction, // Hide debug banner in production
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
