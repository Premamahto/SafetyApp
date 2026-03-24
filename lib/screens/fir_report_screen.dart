import 'package:flutter/material.dart';
import '../models/emergency_model.dart';
import '../services/pdf_service.dart';

/// FIR Report screen — shows full incident details and lets user generate/share FIR PDF
/// Used by both Women and Police roles
class FirReportScreen extends StatelessWidget {
  final EmergencyModel emergency;

  const FirReportScreen({super.key, required this.emergency});

  Color get _statusColor {
    switch (emergency.status) {
      case EmergencyStatus.helpRequested:
        return Colors.red;
      case EmergencyStatus.policeOnTheWay:
        return Colors.orange;
      case EmergencyStatus.rescued:
        return Colors.green;
      case EmergencyStatus.safetyConfirmed:
        return Colors.blue;
    }
  }

  String get _statusText {
    switch (emergency.status) {
      case EmergencyStatus.helpRequested:
        return 'Help Requested';
      case EmergencyStatus.policeOnTheWay:
        return 'Police On The Way';
      case EmergencyStatus.rescued:
        return 'Rescued';
      case EmergencyStatus.safetyConfirmed:
        return 'Safety Confirmed';
    }
  }

  Future<void> _generateFir(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Generating FIR...')),
      );
      final pdf = await PdfService().generateFirReport(emergency);
      await PdfService().sharePdf(pdf);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details & FIR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate FIR',
            onPressed: () => _generateFir(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    _statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _section('Complainant', [
              _row(Icons.person, 'Name', emergency.userName),
              _row(Icons.phone, 'Phone', emergency.userPhone),
            ]),
            const SizedBox(height: 12),

            _section('Incident', [
              _row(Icons.access_time, 'Date & Time',
                  _fmt(emergency.triggeredAt)),
              _row(Icons.location_on, 'Address', emergency.address),
              _row(Icons.gps_fixed, 'GPS',
                  '${emergency.latitude.toStringAsFixed(6)}, ${emergency.longitude.toStringAsFixed(6)}'),
              _row(Icons.map, 'Google Maps', emergency.googleMapsLink),
            ]),
            const SizedBox(height: 12),

            _section('Police Response', [
              _row(Icons.local_police, 'Officer',
                  emergency.policeName ?? 'Not yet assigned'),
              _row(Icons.badge, 'Officer ID',
                  emergency.policeId ?? 'N/A'),
              _row(Icons.schedule, 'Arrival Time',
                  emergency.policeArrivalTime ?? 'N/A'),
              _row(Icons.check_circle, 'Rescue Completed',
                  emergency.rescueCompletedAt != null
                      ? _fmt(emergency.rescueCompletedAt!)
                      : 'N/A'),
            ]),

            if (emergency.safetyNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              _section('Notes', [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(emergency.safetyNotes!),
                ),
              ]),
            ],

            const SizedBox(height: 24),

            // Generate FIR button
            ElevatedButton.icon(
              onPressed: () => _generateFir(context),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate & Share FIR Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
