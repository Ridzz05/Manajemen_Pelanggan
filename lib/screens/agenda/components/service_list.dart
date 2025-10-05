import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/service_provider.dart';
import '../../../models/service.dart';
import 'service_card.dart';
import 'services_empty_state.dart';

/// Service list component that handles loading, empty state, and service display
class ServiceList extends StatelessWidget {
  final Function(Service) onEditService;
  final Function(Service) onDeleteService;

  const ServiceList({
    super.key,
    required this.onEditService,
    required this.onDeleteService,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, child) {
          if (serviceProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (serviceProvider.filteredServices.isEmpty) {
            return const ServicesEmptyState();
          }

          return ListView.builder(
            itemCount: serviceProvider.filteredServices.length,
            itemBuilder: (context, index) {
              final service = serviceProvider.filteredServices[index];
              return ServiceCard(
                service: service,
                onActionSelected: (action) {
                  switch (action) {
                    case 'edit':
                      onEditService(service);
                      break;
                    case 'delete':
                      onDeleteService(service);
                      break;
                  }
                },
                onTap: () {
                  // Navigate to service detail (future implementation)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Detail layanan: ${service.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
