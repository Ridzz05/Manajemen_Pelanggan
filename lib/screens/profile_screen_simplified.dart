import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/profile_provider.dart';
import '../providers/statistics_provider.dart';
import '../utils/image_storage.dart';
import '../models/business_profile.dart';

/// Simplified profile screen - only logo and name display
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      'Profil Bisnis',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola informasi bisnis Anda',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              // Simplified Business Profile Section
              Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final profile = profileProvider.profile;

                  return _buildSimplifiedProfileCard(context, profile);
                },
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Aksi Cepat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Quick Action Buttons
              Expanded(
                child: ListView(
                  children: [
                    _buildQuickActionTile(
                      context,
                      Icons.edit_rounded,
                      'Edit Profil',
                      'Ubah informasi bisnis',
                      () => _showEditBusinessDialog(context),
                    ),
                    _buildQuickActionTile(
                      context,
                      Icons.analytics_rounded,
                      'Statistik',
                      'Lihat ringkasan bisnis',
                      () => _showStatisticsDialog(context),
                    ),
                    _buildQuickActionTile(
                      context,
                      Icons.settings_rounded,
                      'Pengaturan',
                      'Konfigurasi aplikasi',
                      () => _showSettingsDialog(context),
                    ),
                    _buildQuickActionTile(
                      context,
                      Icons.info_rounded,
                      'Tentang',
                      'Informasi aplikasi',
                      () => _showAboutDialog(context),
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

  Widget _buildSimplifiedProfileCard(BuildContext context, profile) {
    final hasPhoto = profile?.businessLogo.isNotEmpty ?? false;

    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: FutureBuilder<bool>(
                future: hasPhoto ? ImageStorage.profileImageExists(profile!.businessLogo) : Future.value(false),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.file(
                        File(profile!.businessLogo),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    );
                  } else {
                    return Icon(
                      Icons.business_rounded,
                      size: 24,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),

            // Business Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.businessName ?? 'AWB Auto Workshop',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.businessDescription ?? 'Bengkel Mobil Terpercaya',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Edit Icon
            IconButton(
              onPressed: () => _showEditBusinessDialog(context),
              icon: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.03),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();

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
                'Foto Profil Bisnis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  'Pilih dari Galeri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Pilih gambar dari galeri perangkat',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await profileProvider.pickAndSaveImage();
                  if (imagePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto profil berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal memilih foto profil'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              if (profileProvider.profile?.businessLogo.isNotEmpty ?? false) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.red,
                    ),
                  ),
                  title: Text(
                    'Hapus Foto Profil',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Hapus foto profil saat ini',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await profileProvider.deleteProfilePhoto();
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Foto profil berhasil dihapus'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Gagal menghapus foto profil'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBusinessDialog(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    final nameController = TextEditingController(text: profile?.businessName ?? '');
    final descriptionController = TextEditingController(text: profile?.businessDescription ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profil Bisnis'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bisnis',
                  hintText: 'Masukkan nama bisnis',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Bisnis',
                  hintText: 'Masukkan deskripsi bisnis',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama bisnis dan deskripsi harus diisi'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final updatedProfile = (profile ?? BusinessProfile.defaultProfile()).copyWith(
                  businessName: nameController.text,
                  businessDescription: descriptionController.text,
                  updatedAt: DateTime.now(),
                );

                final success = await profileProvider.updateProfile(updatedProfile);

                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil bisnis berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal memperbarui profil bisnis'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ringkasan Bisnis'),
          content: Consumer<StatisticsProvider>(
            builder: (context, statsProvider, child) {
              final stats = statsProvider.statistics;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total Pelanggan', stats.totalCustomers.toString()),
                  _buildStatRow('Total Layanan', stats.totalServices.toString()),
                  _buildStatRow('Layanan Terpopuler', stats.mostPopularService),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pengaturan Sistem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tema: Terang', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Bahasa: Indonesia', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('Notifikasi: Aktif', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tentang Aplikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AWB Management System', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Versi: 1.0.0', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 4),
              Text('Developer: Ridzz Dev', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}
