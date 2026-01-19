import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../models/emergency_model.dart';
import 'safety_confirmation_screen.dart';
import 'emergency_history_screen.dart';

/// Women dashboard screen
/// Main interface for women users with emergency trigger and status
class WomenDashboardScreen extends StatefulWidget {
  const WomenDashboardScreen({super.key});

  @override
  State<WomenDashboardScreen> createState() => _WomenDashboardScreenState();
}

class _WomenDashboardScreenState extends State<WomenDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emergencyProvider = Provider.of<EmergencyProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await emergencyProvider.initialize(authProvider.currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Women Safety Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyHistoryScreen(),
                ),
              );
            },
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
          final currentEmergency = emergencyProvider.currentEmergency;

          if (user == null) {
            return const Center(child: Text('Please login'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stay safe. We\'re here to help.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Emergency Status Card
                if (currentEmergency != null &&
                    currentEmergency.status != EmergencyStatus.safetyConfirmed)
                  _EmergencyStatusCard(emergency: currentEmergency),

                const SizedBox(height: 20),

                // SOS Button
                _SOSButton(
                  onPressed: () async {
                    await emergencyProvider.triggerEmergency(user);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Emergency triggered! Help is on the way.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                // Test Triple Click Button
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Test Emergency Trigger',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Triple-click power button or use button below',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            emergencyProvider.simulateTripleClick();
                          },
                          icon: const Icon(Icons.power_settings_new),
                          label: const Text('Simulate Triple Click'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Safety Confirmation Button
                if (currentEmergency != null &&
                    currentEmergency.status == EmergencyStatus.rescued)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SafetyConfirmationScreen(
                            emergency: currentEmergency,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm I am Safe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Emergency status card widget
class _EmergencyStatusCard extends StatelessWidget {
  final EmergencyModel emergency;

  const _EmergencyStatusCard({required this.emergency});

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
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Unknown';
    }

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(statusIcon, size: 60, color: statusColor),
            const SizedBox(height: 10),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Triggered at: ${emergency.triggeredAt.toString().substring(0, 19)}',
              style: const TextStyle(fontSize: 14),
            ),
            if (emergency.policeName != null) ...[
              const SizedBox(height: 5),
              Text(
                'Officer: ${emergency.policeName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SOS emergency button widget
class _SOSButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SOSButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.red.shade400, Colors.red.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning,
                  size: 60,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'SOS',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Tap for Emergency',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
