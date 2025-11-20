import 'package:flutter/material.dart';
import 'package:mobile_app/config/app_theme.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.event_busy,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: iconSize, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
