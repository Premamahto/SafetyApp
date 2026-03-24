import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_model.dart';
import 'live_map_screen.dart';
import 'emergency_history_screen.dart';
import 'fir_report_screen.dart';

/// Police dashboard screen
/// Shows active emergencies and allows police to respond
class PoliceDashboardScreen extends StatefulWidget {
  const PoliceDashboardScreen({super.key});

  @override
  State<PoliceDashboardScreen> createState() => _PoliceDashboardScreenState();
}

class _PoliceDashboardScreenState extends State<PoliceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _subscribeToEmergencies();
  }

  void _subscribeToEmergencies() {
    final emergencyProvider = Provider.of<EmergencyProvider>(
      context,
      listen: false,
    );
    emergencyProvider.subscribeToActiveEmergencies(() {});
  }

  Future<void> _loadEmergencies() async {
    final emergencyProvider = Provider.of<EmergencyProvider>(
      context,
      listen: false,
    );
    await emergencyProvider.loadActiveEmergencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Police Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Incident History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyHistoryScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmergencies,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/role-selection');
              }
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, EmergencyProvider>(
        builder: (context, authProvider, emergencyProvider, child) {
          final user = authProvider.currentUser;
          final emergencies = emergencyProvider.emergencies;

          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          if (emergencyProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (emergencies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Active Emergencies',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'All clear!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadEmergencies,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: emergencies.length,
              itemBuilder: (context, index) {
                final emergency = emergencies[index];
                return _EmergencyCard(
                  emergency: emergency,
                  policeUser: user,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Emergency card for police dashboard
class _EmergencyCard extends StatelessWidget {
  final EmergencyModel emergency;
  final dynamic policeUser;

  const _EmergencyCard({
    required this.emergency,
    required this.policeUser,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (emergency.status) {
      case EmergencyStatus.helpRequested:
        statusColor = Colors.red;
        statusText = 'Help Requested';
        break;
      case EmergencyStatus.policeOnTheWay:
        statusColor = Colors.orange;
        statusText = 'Police On The Way';
        break;
      case EmergencyStatus.rescued:
        statusColor = Colors.green;
        statusText = 'Rescued';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Victim Info
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text(
                  emergency.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Phone
            Row(
              children: [
                const Icon(Icons.phone, size: 20),
                const SizedBox(width: 8),
                Text(emergency.userPhone),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(emergency.address),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(
                  emergency.triggeredAt.toString().substring(0, 19),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveMapScreen(
                            emergency: emergency,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('View Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: emergency.status == EmergencyStatus.helpRequested
                        ? () async {
                            final emergencyProvider =
                                Provider.of<EmergencyProvider>(
                              context,
                              listen: false,
                            );
                            await emergencyProvider.updateStatus(
                              emergency,
                              EmergencyStatus.policeOnTheWay,
                              policeId: policeUser.id,
                              policeName: policeUser.name,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Status updated to On The Way'),
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.directions_car),
                    label: const Text('On The Way'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Rescue Complete Button
            if (emergency.status == EmergencyStatus.policeOnTheWay)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final emergencyProvider = Provider.of<EmergencyProvider>(
                      context,
                      listen: false,
                    );
                    await emergencyProvider.markRescueCompleted(
                      emergency,
                      policeUser.id,
                      policeUser.name,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rescue marked as completed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Rescue Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),

            // Generate FIR button — always available
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FirReportScreen(emergency: emergency),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: const Text('Generate FIR Report',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
