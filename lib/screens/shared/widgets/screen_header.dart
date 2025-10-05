import 'package:flutter/material.dart';

/// Reusable header widget for screen sections
class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsetsGeometry? padding;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
