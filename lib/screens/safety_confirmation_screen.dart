import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/emergency_model.dart';
import '../providers/emergency_provider.dart';
import '../services/pdf_service.dart';

/// Safety confirmation screen
/// Allows women to confirm safety and generate report
class SafetyConfirmationScreen extends StatefulWidget {
  final EmergencyModel emergency;

  const SafetyConfirmationScreen({super.key, required this.emergency});

  @override
  State<SafetyConfirmationScreen> createState() =>
      _SafetyConfirmationScreenState();
}

class _SafetyConfirmationScreenState extends State<SafetyConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _arrivalTimeController = TextEditingController();
  final _notesController = TextEditingController();
  final PdfService _pdfService = PdfService();

  @override
  void dispose() {
    _arrivalTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Confirm safety
  Future<void> _confirmSafety() async {
    if (!_formKey.currentState!.validate()) return;

    final emergencyProvider = Provider.of<EmergencyProvider>(
      context,
      listen: false,
    );

    await emergencyProvider.confirmSafety(
      widget.emergency,
      _arrivalTimeController.text,
      _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safety confirmed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  /// Generate and download safety report
  Future<void> _generateReport() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdfFile = await _pdfService.generateSafetyReport(widget.emergency);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show options to share or print
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Generated'),
          content: const Text('What would you like to do with the report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                await _pdfService.sharePdf(pdfFile);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () async {
                await _pdfService.printPdf(pdfFile);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Print'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Safety'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              const Icon(
                Icons.check_circle,
                size: 100,
                color: Colors.green,
              ),
              const SizedBox(height: 20),

              const Text(
                'You are Safe!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'Please provide the following information to complete your safety report.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Emergency Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Triggered At',
                        widget.emergency.triggeredAt
                            .toString()
                            .substring(0, 19),
                      ),
                      _buildInfoRow('Location', widget.emergency.address),
                      if (widget.emergency.policeName != null)
                        _buildInfoRow(
                          'Responding Officer',
                          widget.emergency.policeName!,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Police Arrival Time
              TextFormField(
                controller: _arrivalTimeController,
                decoration: InputDecoration(
                  labelText: 'Police Arrival Time',
                  hintText: 'e.g., 10:30 AM',
                  prefixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter police arrival time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Optional Notes
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Any additional information...',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Confirm Safety Button
              ElevatedButton.icon(
                onPressed: _confirmSafety,
                icon: const Icon(Icons.check),
                label: const Text('Confirm I am Safe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),

              // Generate Report Button
              OutlinedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate Safety Report'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
