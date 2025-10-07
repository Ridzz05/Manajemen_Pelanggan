// melakukan import package material.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyek_mahasiswa/theme/app_theme.dart';
import 'package:proyek_mahasiswa/screens/main_screen.dart';
import 'package:proyek_mahasiswa/providers/statistics_provider.dart';
import 'package:proyek_mahasiswa/providers/customer_provider.dart';
import 'package:proyek_mahasiswa/providers/service_provider.dart';
import 'package:proyek_mahasiswa/providers/profile_provider.dart';

void main() {
  // Initialize sqflite for desktop platforms
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'CRM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
