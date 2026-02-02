import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../models/statistics.dart';
import 'shared/widgets/chart_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatisticsProvider>(context, listen: false).loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: _buildHeader(theme),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: Consumer<StatisticsProvider>(
                  builder: (context, statsProvider, child) {
                    if (statsProvider.isLoading) {
                      return SliverToBoxAdapter(
                        child: Container(
                          height: isWide ? 260 : 220,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }

                    final stats = statsProvider.statistics;

                    return SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryGrid(context, stats, isWide),
                          const SizedBox(height: 16),
                          _buildPopularServiceCard(context, stats),
                          const SizedBox(height: 16),
                          ChartContainer(
                            title: 'Distribusi Layanan',
                            child: _buildPieChart(context, stats),
                          ),
                          const SizedBox(height: 16),
                          ChartContainer(
                            title: 'Pertumbuhan Bulanan',
                            child: _buildBarChart(context, stats),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aktivitas Terbaru',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (stats.recentCustomers.isNotEmpty) ...[
                            _buildSectionHeader('Pelanggan Baru', theme.colorScheme.primary),
                            const SizedBox(height: 8),
                            ...stats.recentCustomers.take(3).map(
                              (customer) => _buildRecentActivityCard(
                                context,
                                customer.name,
                                'Pelanggan baru ditambahkan',
                                Icons.person_add_outlined,
                                theme.colorScheme.primary,
                                customer.createdAt,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (stats.recentCategories.isNotEmpty) ...[
                            _buildSectionHeader('Kategori Layanan Baru', theme.colorScheme.secondary),
                            const SizedBox(height: 8),
                            ...stats.recentCategories.take(3).map(
                              (categoryMap) => _buildRecentActivityCard(
                                context,
                                categoryMap['name'],
                                'Kategori baru',
                                Icons.category_outlined,
                                theme.colorScheme.secondary,
                                DateTime.parse(categoryMap['created_at']),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Ringkasan performa bisnis Anda',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    StatisticsData stats,
    bool isWide,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Pelanggan',
            stats.totalCustomers.toString(),
            Icons.people_outline_rounded,
            Colors.blue,
            isWide,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total Layanan',
            stats.totalServices.toString(),
            Icons.layers_outlined,
            Colors.green,
            isWide,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isWide,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(isWide ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularServiceCard(BuildContext context, StatisticsData stats) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layanan Terpopuler',
                  style: theme.textTheme.labelMedium?.copyWith(
                     color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  stats.mostPopularService,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${stats.mostPopularServiceCount} kali digunakan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, StatisticsData stats) {
    if (stats.serviceDistributionData.isEmpty) {
      return const EmptyChartState();
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: stats.serviceDistributionData,
          sectionsSpace: 0,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, StatisticsData stats) {
    if (stats.monthlyGrowthData.isEmpty) {
      return const EmptyChartState();
    }

    return SizedBox(
      height: 200,
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        months[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color color, 
    DateTime date
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 20),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Text(
          _formatDate(date),
          style: TextStyle(
            fontSize: 12, 
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Kemarin';
    } else if (difference < 7) {
      return '$difference hari lalu';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} minggu lalu';
    } else {
      return '${(difference / 30).floor()} bulan lalu';
    }
  }
}
