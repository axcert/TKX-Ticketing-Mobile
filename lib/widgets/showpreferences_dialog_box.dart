import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';

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
          color: AppColors.divider,
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
                Text(
                  'Scanner Preferences',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w900,
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
            Divider(color: AppColors.textHint.withOpacity(0.3)),
            const SizedBox(height: 16),

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
            Divider(color: AppColors.textHint.withOpacity(0.3)),
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
            Divider(color: AppColors.textHint.withOpacity(0.3)),
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
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontFamily: GoogleFonts.inter().fontFamily,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: AppColors.background,
          inactiveTrackColor: AppColors.border,
          trackOutlineColor: WidgetStatePropertyAll(AppColors.divider),
        ),
      ],
    );
  }
}
