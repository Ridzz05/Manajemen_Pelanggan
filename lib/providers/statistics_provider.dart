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

      // Get all customers and categories
      final customers = await dbHelper.getAllCustomers();
      final categories = await dbHelper.getCategories();

      // Get recent data
      final recentCustomers = await dbHelper.getRecentCustomers(limit: 5);
      final recentCategories = await dbHelper.getRecentCategories(limit: 5); // Use new method

      // Calculate Most Popular Service (Category) from Customer Data
      Map<String, int> popularityMap = {};
      for (var customer in customers) {
        for (var cat in customer.serviceCategories) {
          popularityMap[cat] = (popularityMap[cat] ?? 0) + 1;
        }
      }
      
      String mostPopularService = 'Tidak ada data';
      int mostPopularServiceCount = 0;

      if (popularityMap.isNotEmpty) {
        var sortedEntries = popularityMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        mostPopularService = sortedEntries.first.key;
        mostPopularServiceCount = sortedEntries.first.value;
      }
      
      // Calculate Service Distribution for Pie Chart based on Customer Usage
      // If popularityMap is empty (no customers), show distribution of available categories (count=1) or 0
      final categoryCountForChart = popularityMap.isNotEmpty 
          ? popularityMap 
          : { for (var e in categories) e : 0 }; 

      // Generate pie chart data
      final pieChartData = _generatePieChartData(categoryCountForChart);

      // Get real monthly growth data from database
      final monthlyGrowthData = await _generateMonthlyGrowthDataFromDBAsync();

      _statistics = StatisticsData(
        totalCustomers: customers.length,
        totalServices: categories.length, // Count categories
        mostPopularService: mostPopularService,
        mostPopularServiceCount: mostPopularServiceCount,
        recentCustomers: recentCustomers,
        recentCategories: recentCategories, // Pass recent categories
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

  List<PieChartSectionData> _generatePieChartData(
    Map<String, int> categoryCount,
  ) {
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

  Future<List<BarChartGroupData>>
  _generateMonthlyGrowthDataFromDBAsync() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final growthData = await dbHelper.getMonthlyGrowthData(months: 6);

      final customers = growthData['customers'] ?? [];
      final services = growthData['services'] ?? [];

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
    } catch (e) {
      print('Error generating monthly growth data: $e');
      return [];
    }
  }

  Future<void> refreshData() async {
    await loadStatistics();
  }
}
