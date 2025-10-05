import 'package:flutter/material.dart';

/// Base class for statistics cards used across the app
abstract class BaseStatsCard extends StatelessWidget {
  const BaseStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getIcon(context),
          const SizedBox(height: 8),
          getValueText(context),
          const SizedBox(height: 4),
          getTitleText(context),
        ],
      ),
    );
  }

  Color getCardColor(BuildContext context);
  Color getBorderColor(BuildContext context);
  Widget getIcon(BuildContext context);
  Widget getValueText(BuildContext context);
  Widget getTitleText(BuildContext context);
}

/// Summary card for displaying statistics like total customers, services, etc.
class SummaryCard extends BaseStatsCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Color getCardColor(BuildContext context) => color.withOpacity(0.1);

  @override
  Color getBorderColor(BuildContext context) => color.withOpacity(0.2);

  @override
  Widget getIcon(BuildContext context) => Icon(icon, color: color, size: 24);

  @override
  Widget getValueText(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  @override
  Widget getTitleText(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: color.withOpacity(0.8),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
