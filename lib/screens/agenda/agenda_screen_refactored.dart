import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service.dart';
import 'components/agenda_header.dart';
import 'components/service_list.dart';
import 'components/edit_service_dialog.dart';
import 'components/delete_service_dialog.dart';
import '../shared/widgets/custom_search_bar.dart';

/// Refactored agenda screen with modular components
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load services when screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              const AgendaHeader(),

              // Search Bar
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Cari layanan...',
                onChanged: (value) {
                  context.read<ServiceProvider>().searchServices(value);
                },
                onClear: () {
                  context.read<ServiceProvider>().searchServices('');
                },
              ),

              // Service List
              ServiceList(
                onEditService: _showEditServiceDialog,
                onDeleteService: _showDeleteConfirmation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditServiceDialog(Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditServiceDialog(service: service);
      },
    );
  }

  void _showDeleteConfirmation(Service service) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteServiceDialog(service: service);
      },
    );
  }
}
