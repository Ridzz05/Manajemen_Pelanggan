import '../models/customer.dart';
import '../models/service.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsData {
  final int totalCustomers;
  final int totalServices;
  final String mostPopularService;
  final int mostPopularServiceCount;
  final List<Customer> recentCustomers;
  final List<Map<String, dynamic>> recentCategories;
  final List<PieChartSectionData> serviceDistributionData;
  final List<BarChartGroupData> monthlyGrowthData;

  StatisticsData({
    required this.totalCustomers,
    required this.totalServices,
    required this.mostPopularService,
    required this.mostPopularServiceCount,
    required this.recentCustomers,
    required this.recentCategories,
    required this.serviceDistributionData,
    required this.monthlyGrowthData,
  });

  factory StatisticsData.empty() {
    return StatisticsData(
      totalCustomers: 0,
      totalServices: 0,
      mostPopularService: 'Tidak ada data',
      mostPopularServiceCount: 0,
      recentCustomers: [],
      recentCategories: [],
      serviceDistributionData: [],
      monthlyGrowthData: [],
    );
  }
}
