import 'package:flutter/material.dart';
import 'package:proyek_mahasiswa/widgets/profile_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), // Mengurangi horizontal padding dari 20 ke 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profil',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gatau males pengen beli truk',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Profile Info
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'RM',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ridzz Dev',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sistem Informasi • Angkatan 2024',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Settings Section
              Text(
                'Pengaturan Akun',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Profile Tiles
              Expanded(
                child: ListView(
                  children: const [
                    ProfileTile(
                      icon: Icons.lock_outline,
                      title: 'Keamanan dan Privasi',
                      subtitle: 'Kelola kata sandi dan autentikasi dua faktor',
                    ),
                    ProfileTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi',
                      subtitle: 'Atur preferensi pemberitahuan aplikasi',
                    ),
                    ProfileTile(
                      icon: Icons.help_outline,
                      title: 'Pusat Bantuan',
                      subtitle: 'Ajukan pertanyaan dan hubungi tim bantuan',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
