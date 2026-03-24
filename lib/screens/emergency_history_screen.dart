import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_model.dart';
import 'fir_report_screen.dart';

/// Emergency history screen — Women & Police
/// Shows all past incidents with FIR generation on each
class EmergencyHistoryScreen extends StatefulWidget {
  const EmergencyHistoryScreen({super.key});

  @override
  State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ep = Provider.of<EmergencyProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;

    if (user.role.toString().contains('police')) {
      await ep.loadActiveEmergencies();
    } else {
      await ep.loadUserEmergencies(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident History'),
      ),
      body: Consumer<EmergencyProvider>(
        builder: (context, ep, _) {
          if (ep.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ep.emergencies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No incidents found',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ep.emergencies.length,
              itemBuilder: (context, i) =>
                  _HistoryCard(emergency: ep.emergencies[i]),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final EmergencyModel emergency;
  const _HistoryCard({required this.emergency});

  Color get _color {
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

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status chip + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(_statusText,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Text(_fmt(emergency.triggeredAt),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 10),

            // Victim name
            Row(children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(emergency.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),

            // Location
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(emergency.address,
                      style: const TextStyle(fontSize: 13))),
            ]),

            if (emergency.policeName != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.local_police, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Officer: ${emergency.policeName}',
                    style: const TextStyle(fontSize: 13)),
              ]),
            ],

            const SizedBox(height: 12),

            // View Details + Generate FIR
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FirReportScreen(emergency: emergency),
                      ),
                    ),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FirReportScreen(emergency: emergency),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Generate FIR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
