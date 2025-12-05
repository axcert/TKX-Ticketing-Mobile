import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tkx_ticketing/providers/auth_provider.dart';

class ShowPreferencesDialogBox extends StatefulWidget {
  final Function(bool vibrateOnScan, bool beepOnScan, bool autoCheckIn)
  onPreferencesChanged;

  const ShowPreferencesDialogBox({
    super.key,
    required this.onPreferencesChanged,
  });

  /// Static method to show the dialog
  static void show(
    BuildContext context, {
    required Function(bool vibrateOnScan, bool beepOnScan, bool autoCheckIn)
    onPreferencesChanged,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ShowPreferencesDialogBox(
          onPreferencesChanged: onPreferencesChanged,
        );
      },
    );
  }

  @override
  State<ShowPreferencesDialogBox> createState() =>
      _ShowPreferencesDialogBoxState();
}

class _ShowPreferencesDialogBoxState extends State<ShowPreferencesDialogBox> {
  late bool _vibrateOnScan;
  late bool _beepOnScan;
  late bool _autoCheckIn;
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _vibrateOnScan = authProvider.user!.isVibrate ?? true;
    _beepOnScan = authProvider.user!.isBeep ?? false;
    _autoCheckIn = authProvider.user!.isAutoCheckIn ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanner Preferences',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      widget.onPreferencesChanged(
                        _vibrateOnScan,
                        _beepOnScan,
                        _autoCheckIn,
                      );
                    });
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Vibrate option
            _buildPreferenceOption(
              title: 'Vibrate',
              subtitle: 'Vibrate if scan is successful',
              value: _vibrateOnScan,
              onChanged: (value) {
                setState(() {
                  _vibrateOnScan = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Beep option
            _buildPreferenceOption(
              title: 'Beep',
              subtitle: 'Beep if scan is successful',
              value: _beepOnScan,
              onChanged: (value) {
                setState(() {
                  _beepOnScan = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Auto Check-in option
            _buildPreferenceOption(
              title: 'Auto Check-in',
              subtitle: 'Scans check in automatically',
              value: _autoCheckIn,
              onChanged: (value) {
                setState(() {
                  _autoCheckIn = value;
                });
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
          thumbColor: const WidgetStatePropertyAll(Color(0xFF6366F1)),
        ),
      ],
    );
  }
}
