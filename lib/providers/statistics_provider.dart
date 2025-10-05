import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/statistics.dart';
import '../database/database_helper.dart';

class StatisticsProvider extends ChangeNotifier {
  StatisticsData _statistics = StatisticsData.empty();
  bool _isLoading = false;

  StatisticsData get statistics => _statistics;
  bool get isLoading => _isLoading;

  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dbHelper = DatabaseHelper.instance;

      // Get all customers and services
      final customers = await dbHelper.getAllCustomers();
      final services = await dbHelper.getAllServices();

      // Get recent data
      final recentCustomers = await dbHelper.getRecentCustomers(limit: 5);
      final recentServices = await dbHelper.getRecentServices(limit: 5);

      // Get service category distribution for pie chart
      final categoryCount = await dbHelper.getServiceCategoryCount();

      // Find most popular service
      String mostPopularService = 'Tidak ada data';
      int mostPopularServiceCount = 0;

      if (categoryCount.isNotEmpty) {
        final topCategory = categoryCount.entries.first;
        mostPopularService = topCategory.key;
        mostPopularServiceCount = topCategory.value;
      }

      // Generate pie chart data
      final pieChartData = _generatePieChartData(categoryCount);

      // Generate monthly growth data (dummy data for now)
      final monthlyGrowthData = _generateMonthlyGrowthData();

      _statistics = StatisticsData(
        totalCustomers: customers.length,
        totalServices: services.length,
        mostPopularService: mostPopularService,
        mostPopularServiceCount: mostPopularServiceCount,
        recentCustomers: recentCustomers,
        recentServices: recentServices,
        serviceDistributionData: pieChartData,
        monthlyGrowthData: monthlyGrowthData,
      );

    } catch (e) {
      print('Error loading statistics: $e');
      _statistics = StatisticsData.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PieChartSectionData> _generatePieChartData(Map<String, int> categoryCount) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return categoryCount.entries.map((entry) {
      final index = categoryCount.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _generateMonthlyGrowthData() {
    // Dummy data untuk 6 bulan terakhir
    final customers = [12, 19, 15, 25, 22, 18];
    final services = [8, 15, 12, 20, 18, 14];

    return List.generate(6, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: customers[index].toDouble(),
            color: Colors.blue,
            width: 12,
          ),
          BarChartRodData(
            toY: services[index].toDouble(),
            color: Colors.green,
            width: 12,
          ),
        ],
      );
    });
  }

  Future<void> refreshData() async {
    await loadStatistics();
  }
}
