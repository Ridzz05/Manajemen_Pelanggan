import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/statistics_provider.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/popular_service_card.dart';
import '../../shared/widgets/recent_activity_card.dart';
import '../../shared/widgets/chart_container.dart';

/// Statistics section component for home screen
class HomeStatisticsSection extends StatelessWidget {
  const HomeStatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return const Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final stats = statsProvider.statistics;

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Pelanggan',
                        value: stats.totalCustomers.toString(),
                        icon: Icons.people_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Layanan',
                        value: stats.totalServices.toString(),
                        icon: Icons.business_rounded,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Most Popular Service Card
                PopularServiceCard(
                  serviceName: stats.mostPopularService,
                  usageCount: stats.mostPopularServiceCount,
                ),
                const SizedBox(height: 20),

                // Service Distribution Chart
                ChartContainer(
                  title: 'Distribusi Layanan',
                  child: _buildPieChart(context, stats),
                ),
                const SizedBox(height: 24),

                // Monthly Growth Chart
                ChartContainer(
                  title: 'Pertumbuhan Bulanan',
                  child: _buildBarChart(context, stats),
                ),
                const SizedBox(height: 24),

                // Recent Activity Section
                Text(
                  'Aktivitas Terbaru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Customers
                if (stats.recentCustomers.isNotEmpty) ...[
                  Text(
                    'Pelanggan Baru',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.recentCustomers.take(3).map(
                    (customer) => RecentActivityCard(
                      title: customer.name,
                      subtitle: 'Pelanggan baru ditambahkan',
                      icon: Icons.person_add_rounded,
                      color: Colors.blue,
                      date: customer.createdAt,
                      formatDate: formatActivityDate,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recent Services (Categories)
                if (stats.recentCategories.isNotEmpty) ...[
                  Text(
                    'Kategori Layanan Baru',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...stats.recentCategories.take(3).map(
                    (categoryMap) => RecentActivityCard(
                      title: categoryMap['name'],
                      subtitle: 'Kategori baru',
                      icon: Icons.category_rounded,
                      color: Colors.green,
                      date: DateTime.parse(categoryMap['created_at']),
                      formatDate: formatActivityDate,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPieChart(BuildContext context, stats) {
    if (stats.serviceDistributionData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyChartState(),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: stats.serviceDistributionData,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, stats) {
    if (stats.monthlyGrowthData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: EmptyChartState(),
      );
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: stats.monthlyGrowthData,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                  if (value.toInt() >= 0 && value.toInt() < months.length) {
                    return Text(
                      months[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
