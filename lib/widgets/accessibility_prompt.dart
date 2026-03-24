import 'package:flutter/material.dart';
import '../services/volume_button_service.dart';

/// Banner shown on the women's dashboard when OUR accessibility service
/// ("Women Safety Monitor") is not yet enabled.
///
/// Uses WidgetsBindingObserver to re-check when the user returns from
/// Android Accessibility Settings — so the banner auto-dismisses.
class AccessibilityPrompt extends StatefulWidget {
  const AccessibilityPrompt({super.key});

  @override
  State<AccessibilityPrompt> createState() => _AccessibilityPromptState();
}

class _AccessibilityPromptState extends State<AccessibilityPrompt>
    with WidgetsBindingObserver {
  final _svc = VolumeButtonService();
  bool _enabled = true; // optimistic default — hides banner until first check

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called whenever the app comes back to the foreground (e.g. returning
  /// from Accessibility Settings). This is what makes the banner auto-dismiss.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    final enabled = await _svc.isAccessibilityEnabled();
    if (mounted) setState(() => _enabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    if (_enabled) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Background SOS not active',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'To trigger SOS with the volume button when the app is in the background, '
            'enable "Women Safety Monitor" in Accessibility Settings.',
            style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
          ),
          const SizedBox(height: 4),
          Text(
            'Steps: tap "Open Settings" → Installed apps → Women Safety Monitor → turn ON',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.accessibility_new),
              label: const Text('Open Accessibility Settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange.shade800,
                side: BorderSide(color: Colors.orange.shade400),
              ),
              onPressed: () => _svc.openAccessibilitySettings(),
            ),
          ),
        ],
      ),
    );
  }
}
