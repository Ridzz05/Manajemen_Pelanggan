import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../utils/image_storage.dart';
import 'dart:io';
import 'package:proyek_mahasiswa/screens/home_screen.dart';
import 'package:proyek_mahasiswa/screens/explore_screen.dart';
import 'package:proyek_mahasiswa/screens/agenda_screen.dart';
import 'package:proyek_mahasiswa/screens/profile_screen.dart';
import 'package:proyek_mahasiswa/screens/add_customer_screen.dart';
import 'package:proyek_mahasiswa/screens/add_service_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: FutureBuilder<bool>(
                    future: hasPhoto ? ImageStorage.profileImageExists(profile!.businessLogo) : Future.value(false),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(profile!.businessLogo),
                            fit: BoxFit.cover,
                            width: 32,
                            height: 32,
                          ),
                        );
                      } else {
                        return Icon(
                          Icons.article_rounded,
                          color: Colors.white,
                          size: 20,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'AWBuilder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _buildPageContent(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 68, // Further reduced height for mobile
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Minimal padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dashboard
                Expanded(
                  flex: 1,
                  child: _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Dashboard',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onBottomNavTapped(0),
                  ),
                ),

                // Pelanggan
                Expanded(
                  flex: 1,
                  child: _buildNavItem(
                    icon: Icons.search_rounded,
                    label: 'Pelanggan',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onBottomNavTapped(1),
                  ),
                ),

                // Plus Button - Perfectly Centered
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildPlusButton(),
                ),

                // Layanan
                Expanded(
                  flex: 1,
                  child: _buildNavItem(
                    icon: Icons.event_note_rounded,
                    label: 'Layanan',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onBottomNavTapped(3),
                  ),
                ),

                // Profil
                Expanded(
                  flex: 1,
                  child: _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profil',
                    isSelected: _selectedIndex == 4,
                    onTap: () => _onBottomNavTapped(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Even smaller padding
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14), // Smaller radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: isSelected ? 20 : 18, // Smaller icons for mobile
            ),
            const SizedBox(height: 1), // Minimal spacing
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10, // Smaller text for mobile
                height: 1.1, // Tighter line height
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusButton() {
    return GestureDetector(
      onTap: () {
        _showAddOptions();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38, // Smallest optimal size for mobile
        height: 38, // Smallest optimal size for mobile
        margin: const EdgeInsets.symmetric(horizontal: 2), // Minimal margin
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(17), // Proportional radius
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25),
              blurRadius: 3, // Minimal blur for mobile
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 18, // Proportional icon size
        ),
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tambah Baru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Tambah Pelanggan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Tambahkan pelanggan baru ke sistem',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddCustomerScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_business_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: Text(
                  'Tambah Layanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Tambahkan layanan baru untuk pelanggan',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddServiceScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageContent(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey(0));
      case 1:
        return const ExploreScreen(key: ValueKey(1));
      case 2:
        return const HomeScreen(key: ValueKey(2));
      case 3:
        return const AgendaScreen(key: ValueKey(3));
      case 4:
      default:
        return const ProfileScreen(key: ValueKey(4));
    }
  }
}
