import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_model.dart';
import '../services/pdf_service.dart';

/// Emergency history screen
/// Shows past emergencies for women users
class EmergencyHistoryScreen extends StatelessWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency History'),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, emergencyProvider, child) {
          final emergencies = emergencyProvider.emergencies;

          if (emergencies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No Emergency History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: emergencies.length,
            itemBuilder: (context, index) {
              final emergency = emergencies[index];
              return _EmergencyHistoryCard(emergency: emergency);
            },
          );
        },
      ),
    );
  }
}

/// Emergency history card widget
class _EmergencyHistoryCard extends StatelessWidget {
  final EmergencyModel emergency;

  const _EmergencyHistoryCard({required this.emergency});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (emergency.status) {
      case EmergencyStatus.helpRequested:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'Help Requested';
        break;
      case EmergencyStatus.policeOnTheWay:
        statusColor = Colors.orange;
        statusIcon = Icons.directions_car;
        statusText = 'Police On The Way';
        break;
      case EmergencyStatus.rescued:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Rescued';
        break;
      case EmergencyStatus.safetyConfirmed:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        statusText = 'Safety Confirmed';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),

            // Date & Time
            _buildInfoRow(
              Icons.access_time,
              'Triggered',
              emergency.triggeredAt.toString().substring(0, 19),
            ),

            // Location
            _buildInfoRow(
              Icons.location_on,
              'Location',
              emergency.address,
            ),

            // Police Officer
            if (emergency.policeName != null)
              _buildInfoRow(
                Icons.local_police,
                'Officer',
                emergency.policeName!,
              ),

            // Arrival Time
            if (emergency.policeArrivalTime != null)
              _buildInfoRow(
                Icons.schedule,
                'Arrival Time',
                emergency.policeArrivalTime!,
              ),

            // Notes
            if (emergency.safetyNotes != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(emergency.safetyNotes!),
            ],

            // Download Report Button
            if (emergency.status == EmergencyStatus.safetyConfirmed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final pdfService = PdfService();
                    try {
                      final pdfFile = await pdfService.generateSafetyReport(
                        emergency,
                      );
                      await pdfService.sharePdf(pdfFile);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Report'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
