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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;
            final contentWidth = constraints.maxWidth - 32;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 24),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil Bisnis',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kelola semua informasi bisnis Anda',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSimplifiedProfileCard(BuildContext context, profile, bool isWide, {Key? key}) {
    final hasPhoto = profile?.businessLogo.isNotEmpty ?? false;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      key: key,
      padding: EdgeInsets.all(isWide ? 24 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: isWide ? 80 : 72,
                width: isWide ? 80 : 72,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<bool>(
                  future: hasPhoto ? ImageStorage.profileImageExists(profile!.businessLogo) : Future.value(false),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(profile!.businessLogo),
                          fit: BoxFit.cover,
                          width: isWide ? 80 : 72,
                          height: isWide ? 80 : 72,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
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
                      profile?.businessName ?? 'Nama Bisnis',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.businessDescription ?? 'Deskripsi bisnis Anda',
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
                  Icons.edit_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showPhotoOptions(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasPhoto ? 'Ubah logo bisnis' : 'Tambahkan logo bisnis',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isWide, double contentWidth) {
    final tiles = [
      _buildQuickActionTile(
        context,
        Icons.analytics_outlined,
        'Statistik',
        'Ringkasan bisnis',
        () => _showStatisticsDialog(context),
      ),
      _buildQuickActionTile(
        context,
        Icons.settings_outlined,
        'Pengaturan',
        'Konfigurasi sistem',
        () => _showSettingsDialog(context),
      ),
      _buildQuickActionTile(
        context,
        Icons.info_outline_rounded,
        'Tentang',
        'Info aplikasi',
        () => _showAboutDialog(context),
      ),
    ];

    if (!isWide) {
      return Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1) const SizedBox(height: 8),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onSecondaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.outline,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simplified dialogs
  void _showPhotoOptions(BuildContext context) {
    // ... logic remains same, simplify UI inside if needed, but standard ListTiles are fine
    // For now keeping logic mostly same but just ensure no heavy styling
    final profileProvider = context.read<ProfileProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await profileProvider.pickAndSaveImage();
                  if (!context.mounted) return;
                  if (imagePath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Foto profil diperbarui')),
                    );
                  }
                },
              ),
              if (profileProvider.profile?.businessLogo.isNotEmpty ?? false)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await profileProvider.deleteProfilePhoto();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showEditBusinessDialog(BuildContext context) {
    // Standard Dialog is okay, just ensure content is simple
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;
    final nameController = TextEditingController(text: profile?.businessName ?? '');
    final descriptionController = TextEditingController(text: profile?.businessDescription ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Bisnis'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final updated = (profile ?? BusinessProfile.defaultProfile()).copyWith(
                businessName: nameController.text,
                businessDescription: descriptionController.text,
                updatedAt: DateTime.now(),
              );
              await profileProvider.updateProfile(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistik'),
        content: Consumer<StatisticsProvider>(
          builder: (context, stats, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow(context, 'Total Pelanggan', '${stats.statistics.totalCustomers}'),
              _buildStatRow(context, 'Total Layanan', '${stats.statistics.totalServices}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Versi: 1.0.0'),
             SizedBox(height: 8),
             Text('Mode: Terang'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang'),
        content: const Text('Manajemen Pelanggan v1.0\nDeveloped by Ridzz Dev'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
        ],
      ),
    );
  }
}
