import 'package:flutter/material.dart';

/// Configuration class for navigation items
class NavigationItem {
  final IconData icon;
  final String label;
  final String? badge;

  const NavigationItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}

/// Main bottom navigation bar widget
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function() onPlusTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPlusTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  /// Navigation items configuration
  final List<NavigationItem> _navItems = const [
    NavigationItem(icon: Icons.grid_view_rounded, label: 'Dash'),
    NavigationItem(icon: Icons.people_outline_rounded, label: 'Pelanggan'),
    NavigationItem(icon: Icons.event_note_rounded, label: 'Layanan'),
    NavigationItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dashboard & Pelanggan
              ..._navItems.take(2).map((item) => Expanded(
                child: NavItem(
                  item: item,
                  isSelected: _getItemIndex(item) == widget.currentIndex,
                  onTap: () => widget.onTap(_getItemIndex(item)),
                ),
              )),

              // Plus Button
              const SizedBox(width: 8), // Spacing for dynamic feel
              PlusButton(onTap: widget.onPlusTap),
              const SizedBox(width: 8), // Spacing for dynamic feel

              // Layanan & Profil
              ..._navItems.skip(2).map((item) => Expanded(
                child: NavItem(
                  item: item,
                  isSelected: _getItemIndex(item) == widget.currentIndex,
                  onTap: () => widget.onTap(_getItemIndex(item)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  int _getItemIndex(NavigationItem item) {
    return _navItems.indexOf(item);
  }
}

/// Individual navigation item widget
class NavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                item.icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                size: 26,
              ),
            ),
             const SizedBox(height: 4),
            Text(
              item.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Plus button widget for adding new items
class PlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const PlusButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
             BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
