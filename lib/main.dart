// melakukan import package material.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/theme/app_theme.dart';
import '/screens/main_screen.dart';
import '/providers/statistics_provider.dart';
import '/providers/customer_provider.dart';
import '/providers/service_provider.dart';
import '/providers/profile_provider.dart';
import '/constants/app_config.dart';

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
