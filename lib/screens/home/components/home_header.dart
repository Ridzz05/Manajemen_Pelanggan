import 'package:flutter/material.dart';
import 'package:proyek_mahasiswa/screens/shared/widgets/screen_header.dart';

/// Header component for home screen
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenHeader(
      title: 'Dashboard',
      subtitle: 'Ringkasan bisnis dan statistik pelanggan',
    );
  }
}
