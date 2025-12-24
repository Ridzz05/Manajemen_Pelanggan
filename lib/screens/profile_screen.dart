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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final contentWidth = constraints.maxWidth - 32; // subtract horizontal padding

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.12),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme),
                          const SizedBox(height: 16),
                          Consumer<ProfileProvider>(
                            builder: (context, profileProvider, child) {
                              if (profileProvider.isLoading) {
                                return Container(
                                  height: isWide ? 190 : 170,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              }

                              final profile = profileProvider.profile;

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: _buildSimplifiedProfileCard(
                                  context,
                                  profile,
                                  isWide,
                                  key: ValueKey(profile?.businessLogo ?? profile?.businessName ?? 'profile'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Aksi Cepat',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildQuickActions(context, isWide, contentWidth),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Bisnis',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kelola informasi bisnis Anda',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedProfileCard(BuildContext context, profile, bool isWide, {Key? key}) {
    final hasPhoto = profile?.businessLogo.isNotEmpty ?? false;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: AnimatedContainer(
        key: key,
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isWide ? 24 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isWide ? 76 : 68,
                  width: isWide ? 76 : 68,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 2,
                    ),
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
                            width: isWide ? 76 : 68,
                            height: isWide ? 76 : 68,
                          ),
                        );
                      } else {
                        return Icon(
                          Icons.business_rounded,
                          size: 28,
                          color: colorScheme.onPrimaryContainer,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.businessName ?? 'AWB Auto Workshop',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile?.businessDescription ?? 'Bengkel Mobil Terpercaya',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditBusinessDialog(context),
                  icon: Icon(
                    Icons.edit_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outline.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_camera_back_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasPhoto ? 'Ketuk untuk perbarui logo bisnis' : 'Tambahkan logo agar profil lebih profesional',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isWide, double contentWidth) {
    final tiles = [
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
    ];

    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1) const SizedBox(height: 10),
          ],
        ],
      );
    }

    final tileWidth = (contentWidth - 12) / 2;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tiles
          .map(
            (tile) => SizedBox(
              width: tileWidth,
              child: tile,
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickActionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.outline,
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                  if (!context.mounted) return;

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
                      color: Colors.red.withValues(alpha: 0.1),
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
                    if (!context.mounted) return;

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

                if (!context.mounted) return;

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
