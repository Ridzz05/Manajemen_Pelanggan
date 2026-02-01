import 'package:flutter/material.dart';
import 'package:manajemen_pelanggan/screens/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utils/image_storage.dart';
import 'dart:io';
import '/screens/home_screen.dart';
import '/screens/explore_screen.dart';
import '/screens/agenda_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/add_customer_screen.dart';
import '/screens/add_service_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



// ... imports

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = theme.dividerTheme.color ?? Colors.grey[200]!;

    return Scaffold(
      extendBody: true, // Allow body to extend behind the navbar for the rounded effect
      appBar: AppBar(
        // ... AppBar content (keep existing)
        title: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            final profile = profileProvider.profile;
            final hasPhoto = profile?.businessLogo.isNotEmpty ?? false;

            return Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AWBuilder',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: borderColor,
            height: 1,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildPageContent(_selectedIndex),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        onPlusTap: _showAddOptions,
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat Baru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildOptionTile(
                  icon: Icons.person_add_outlined,
                  title: 'Pelanggan Baru',
                  subtitle: 'Catat data pelanggan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCustomerScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildOptionTile(
                  icon: Icons.post_add_rounded,
                  title: 'Layanan Baru',
                  subtitle: 'Buat katalog layanan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddServiceScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey(0));
      case 1:
        return const ExploreScreen(key: ValueKey(1));
      case 2:
        return const AgendaScreen(key: ValueKey(2));
      case 3:
      default:
        return const ProfileScreen(key: ValueKey(3));
    }
  }
}

